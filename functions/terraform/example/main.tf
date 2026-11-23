# Example root module: deploys the ssh-check function for one or more Exadata
# VM clusters, with the supporting application, logging, optional IAM and an
# hourly Resource Scheduler schedule.
#
# Build and push the image first (see ../../README.md), then pass its
# reference in var.function_image.

resource "oci_functions_application" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "ocidb-monitoring-functions-${var.env}"
  subnet_ids     = var.subnet_ocids

  freeform_tags = var.tags

  lifecycle {
    precondition {
      condition     = length(var.subnet_ocids) > 0 && alltrue([for s in var.subnet_ocids : trimspace(s) != ""])
      error_message = "subnet_ocids must contain at least one non-empty subnet OCID"
    }
  }
}

resource "oci_logging_log_group" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "ocidb-monitoring-functions-${var.env}-logs"
  description    = "Log group for the ocidb-monitoring functions (${var.env})"
  freeform_tags  = var.tags
}

resource "oci_logging_log" "invoke" {
  display_name = "ocidb-monitoring-functions-${var.env}-invoke"
  log_group_id = oci_logging_log_group.this.id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "invoke"
      resource    = oci_functions_application.this.id
      service     = "functions"
      source_type = "OCISERVICE"
    }
  }

  freeform_tags = var.tags
}

# ── Functions ────────────────────────────────────────────────────────────────
module "ssh_check" {
  source   = "../modules/ssh-check"
  for_each = var.clusters

  env         = var.env
  name_suffix = "-${each.key}"
  region      = var.region

  compartment_ocid           = var.compartment_ocid
  discovery_compartment_ocid = var.db_compartment_ocid
  application_ocid           = oci_functions_application.this.id
  function_image             = var.function_image
  vm_cluster_name            = each.value.cluster_name

  ssh_check_target = var.ssh_check_target
  ssh_check_domain = var.ssh_check_domain

  tags = merge(var.tags, { Function = "ssh-check", Cluster = each.value.cluster_name })
}

# ── Schedule ────────────────────────────────────────────────────────────────
# Resource Scheduler's minimum frequency is hourly. If you add more functions,
# put them in separate schedules at different minutes so their cold starts do
# not all hit the Functions service in the same second.
resource "oci_resource_scheduler_schedule" "ssh_check" {
  count = var.scheduler_enabled && length(module.ssh_check) > 0 ? 1 : 0

  compartment_id     = var.compartment_ocid
  display_name       = "ocidb-monitoring-${var.env}-hourly-ssh-check"
  description        = "Invoke the ssh-check functions hourly at minute ${var.scheduler_minute}"
  action             = "START_RESOURCE"
  recurrence_type    = "CRON"
  recurrence_details = "${var.scheduler_minute} * * * *"
  state              = "ACTIVE"

  dynamic "resources" {
    for_each = toset([for m in module.ssh_check : m.function_ocid])
    content {
      id = resources.value
    }
  }

  freeform_tags = var.tags
}

# ── IAM (optional) ──────────────────────────────────────────────────────────
# The functions authenticate as resource principals. The dynamic group matches
# every function in the monitor compartment; the policy grants only what
# ssh-check needs: discover DB nodes, resolve their VNIC IPs, publish metrics.
resource "oci_identity_dynamic_group" "functions" {
  count = var.create_iam ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "ocidb-monitoring-functions-${var.env}-dg"
  description    = "Resource principals for the ocidb-monitoring functions (${var.env})"
  matching_rule  = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_ocid}'}"

  lifecycle {
    precondition {
      condition     = trimspace(var.tenancy_ocid) != ""
      error_message = "tenancy_ocid is required when create_iam is true"
    }
  }
}

resource "oci_identity_policy" "functions" {
  count = var.create_iam ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "ocidb-monitoring-functions-${var.env}-policy"
  description    = "Allow the ssh-check functions to discover DB nodes and publish metrics"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.functions[0].name} to use metrics in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.functions[0].name} to read database-family in compartment id ${var.db_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.functions[0].name} to read virtual-network-family in compartment id ${var.db_compartment_ocid}",
  ]
}

# Resource Scheduler invokes functions through a schedule principal, which has
# no permission by default. Authorize schedules in the monitor compartment to
# manage functions there.
resource "oci_identity_dynamic_group" "schedulers" {
  count = var.create_iam && var.scheduler_enabled ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "ocidb-monitoring-schedulers-${var.env}-dg"
  description    = "Resource Scheduler schedules in the monitor compartment (${var.env})"
  matching_rule  = "ALL {resource.type = 'resourceschedule', resource.compartment.id = '${var.compartment_ocid}'}"
}

resource "oci_identity_policy" "schedulers" {
  count = var.create_iam && var.scheduler_enabled ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "ocidb-monitoring-schedulers-${var.env}-policy"
  description    = "Allow Resource Scheduler schedules to start the monitoring functions"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.schedulers[0].name} to manage functions-family in compartment id ${var.compartment_ocid}",
  ]
}