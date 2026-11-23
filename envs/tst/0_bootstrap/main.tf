module "tf_backend" {
  source             = "../../../modules/s3"
  bucket_name        = "example-iac-terraform-state-tst"
  versioning_enabled = true
  tags               = var.tags
}

# ---------------------------------------------------------------------------
# OCI Compartment for monitoring resources (alarms, dashboards)
# Child compartment under the default resource anchor compartment.
# ---------------------------------------------------------------------------
resource "oci_identity_compartment" "monitor_tst" {
  compartment_id = var.parent_compartment_ocid
  name           = "example_monitor_tst"
  description    = "TST monitoring compartment — OCI alarms and dashboards"
  enable_delete  = true

  freeform_tags = {
    "Environment" = "tst"
    "ManagedBy"   = "terraform"
    "Team"        = "Database Team"
  }
}

output "monitor_compartment_ocid" {
  description = "OCID of the monitor_tst compartment for monitoring/dashboards"
  value       = oci_identity_compartment.monitor_tst.id
}

# ---------------------------------------------------------------------------
# OCI Resource Scheduler authorization for the ocidb-monitoring functions.
#
# Resource Scheduler invokes functions via a schedule principal, which by
# default has no permission to act on target resources. Authorize any resource
# schedule in the monitor_tst compartment to invoke (manage) functions there,
# so scheduled invocation of the monitoring functions works when deployed.
#
# Uses the dynamic-group form (compartment-scoped) rather than a per-schedule
# OCID, so it does not depend on a specific schedule existing first.
# ---------------------------------------------------------------------------
resource "oci_identity_dynamic_group" "tst_resource_schedulers" {
  compartment_id = var.oci_tenancy_ocid
  name           = "example-monitor-tst-resource-schedulers-dg"
  description    = "Resource Scheduler schedules in the example_monitor_tst compartment"
  matching_rule  = "ALL {resource.type='resourceschedule', resource.compartment.id='${oci_identity_compartment.monitor_tst.id}'}"

  freeform_tags = {
    "Environment" = "tst"
    "ManagedBy"   = "terraform"
    "Team"        = "Database Team"
  }
}

resource "oci_identity_policy" "tst_resource_scheduler_invoke" {
  compartment_id = var.oci_tenancy_ocid
  name           = "example-monitor-tst-resource-scheduler-invoke-policy"
  description    = "Allow resource schedules in example_monitor_tst to invoke monitoring functions"

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.tst_resource_schedulers.name} to manage functions-family in compartment id ${oci_identity_compartment.monitor_tst.id}",
  ]

  freeform_tags = {
    "Environment" = "tst"
    "ManagedBy"   = "terraform"
    "Team"        = "Database Team"
  }
}

/*
# Originally for OCI to forward to AWS SNS, however SNS across accounts requires policy to specifically allow.
module "sns_gateway" {
  source = "../../../modules/terraform-aws-apigw-sns"
  api_name                   = "apigateway-sandbox-forwarder"
  api_title                  = "apigateway-sandbox-forwarder"
  topic_arn              = "arn:aws:sns:us-east-1:222222222222:EventBrokerSNS-stg"
  ssm_parameter_name_api_url = "/apigateway-sandbox-forwarder/url"
  ssm_parameter_name_api_key = "/apigateway-sandbox-forwarder/api-key"
}
 */