module "tf_backend" {
  source             = "../../../modules/s3"
  bucket_name        = "example-iac-terraform-state-prd"
  versioning_enabled = true
  tags               = var.tags
}

# ---------------------------------------------------------------------------
# OCI Resource Anchor Compartment (imported, pre-existing)
# This is the default compartment created by AWS for OCI resources.
# Managed here to prevent accidental deletion.
# ---------------------------------------------------------------------------
resource "oci_identity_compartment" "resource_anchor" {
  compartment_id = var.oci_tenancy_ocid
  name           = "111111111111_default-oci-resource-anchor"
  description    = "Default OCI resource anchor compartment for AWS account 111111111111"
  enable_delete  = false

  lifecycle {
    prevent_destroy = true
  }
}

# ---------------------------------------------------------------------------
# Terraform_service Group
# Replaces direct Administrators membership for the iac_admin user.
# Has full admin permissions EXCEPT deleting resources in the resource anchor
# compartment.
# ---------------------------------------------------------------------------
resource "oci_identity_group" "terraform_service" {
  compartment_id = var.oci_tenancy_ocid
  name           = "Terraform_service"
  description    = "Service group for Terraform automation (iac_admin user). Admin permissions with delete restriction on resource anchor compartment."

  freeform_tags = {
    "ManagedBy"   = "terraform"
    "Environment" = "prd"
  }
}

# Add iac_admin user to Terraform_service group
resource "oci_identity_user_group_membership" "iac_admin_terraform_service" {
  group_id = oci_identity_group.terraform_service.id
  user_id  = var.iac_admin_user_ocid
}

# ---------------------------------------------------------------------------
# Policies for Terraform_service group
# ---------------------------------------------------------------------------

# Grant full admin on tenancy (same as Administrators)
resource "oci_identity_policy" "terraform_service_admin" {
  compartment_id = var.oci_tenancy_ocid
  name           = "Terraform_service_admin_policy"
  description    = "Allow Terraform_service group full admin access to all resources EXCEPT the resource anchor compartment"

  statements = [
    "Allow group Terraform_service to manage all-resources in tenancy where target.compartment.id != '${var.oci_resource_anchor_compartment_ocid}'",
  ]

  freeform_tags = {
    "ManagedBy"   = "terraform"
    "Environment" = "prd"
  }
}

# Allow create/manage (but NOT delete) in the resource anchor compartment
resource "oci_identity_policy" "terraform_service_deny_delete_anchor" {
  compartment_id = var.oci_tenancy_ocid
  name           = "Terraform_service_deny_delete_resource_anchor"
  description    = "Allow Terraform_service to manage resources in the anchor compartment except delete operations"

  statements = [
    "Allow group Terraform_service to manage all-resources in compartment id ${var.oci_resource_anchor_compartment_ocid} where all {request.permission != 'DATABASE_DELETE', request.permission != 'DB_HOME_DELETE', request.permission != 'DB_SYSTEM_DELETE', request.permission != 'CLOUD_EXADATA_INFRASTRUCTURE_DELETE', request.permission != 'CLOUD_VM_CLUSTER_DELETE', request.permission != 'COMPARTMENT_DELETE', request.permission != 'PLUGGABLE_DATABASE_DELETE'}",
  ]

  freeform_tags = {
    "ManagedBy"   = "terraform"
    "Environment" = "prd"
  }
}

# ---------------------------------------------------------------------------
# OCI Compartment for monitoring resources (alarms, dashboards, log analytics)
# Sibling of the resource anchor under MulticloudLink.
# ---------------------------------------------------------------------------
resource "oci_identity_compartment" "monitor_prd" {
  compartment_id = var.parent_compartment_ocid
  name           = "example_monitor_prd"
  description    = "PRD monitoring compartment — OCI alarms, dashboards, and log analytics"
  enable_delete  = true

  freeform_tags = {
    "Environment" = "prd"
    "ManagedBy"   = "terraform"
    "Team"        = "Database Team"
  }
}

output "monitor_compartment_ocid" {
  description = "OCID of the monitor_prd compartment for monitoring/dashboards"
  value       = oci_identity_compartment.monitor_prd.id
}

# ---------------------------------------------------------------------------
# OCI Resource Scheduler authorization for the ocidb-monitoring functions.
#
# Resource Scheduler invokes functions via a schedule principal, which by
# default has no permission to act on target resources. Authorize any resource
# schedule in the monitor_prd compartment to invoke (manage) functions there,
# so scheduled invocation of the monitoring functions works when deployed.
#
# Uses the dynamic-group form (compartment-scoped) rather than a per-schedule
# OCID, so it does not depend on a specific schedule existing first.
# ---------------------------------------------------------------------------
resource "oci_identity_dynamic_group" "prd_resource_schedulers" {
  compartment_id = var.oci_tenancy_ocid
  name           = "example-monitor-prd-resource-schedulers-dg"
  description    = "Resource Scheduler schedules in the example_monitor_prd compartment"
  matching_rule  = "ALL {resource.type='resourceschedule', resource.compartment.id='${oci_identity_compartment.monitor_prd.id}'}"

  freeform_tags = {
    "Environment" = "prd"
    "ManagedBy"   = "terraform"
    "Team"        = "Database Team"
  }
}

resource "oci_identity_policy" "prd_resource_scheduler_invoke" {
  compartment_id = var.oci_tenancy_ocid
  name           = "example-monitor-prd-resource-scheduler-invoke-policy"
  description    = "Allow resource schedules in example_monitor_prd to invoke monitoring functions"

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_resource_schedulers.name} to manage functions-family in compartment id ${oci_identity_compartment.monitor_prd.id}",
  ]

  freeform_tags = {
    "Environment" = "prd"
    "ManagedBy"   = "terraform"
    "Team"        = "Database Team"
  }
}


