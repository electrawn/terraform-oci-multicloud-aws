# ---------------------------------------------------------------------------
# Daily spend alarms for the Oracle Database@AWS (ODB) compartment.
#
# The TST pdb-cost-report function (oci-functions terraform/env/dev) publishes,
# once a day, for the ODB compartment "111111111111_default-oci-resource-anchor":
#   odb_compartment_daily_cost                 USD spent on the reported day
#   odb_compartment_daily_cost_30d_avg         average of the previous 30 days
#   odb_compartment_daily_cost_pct_of_30d_avg  reported day as % of that average
# (namespace example_oracledb_aws, dimension compartment_name, in this monitor
# compartment). OCI usage data lags 1-2 days, so the reported day is two days
# before the run (06:15 UTC).
#
# Two alarms: daily spend above a fixed amount, and above a percentage of the
# 30-day average. A datapoint arrives once a day, so each alarm uses a [1d]
# window and stays FIRING until the next day's datapoint is back under.
#
# Not created until cost_alarm_topic_ocids is set (where should cost alerts go?).
# ---------------------------------------------------------------------------

variable "cost_alarm_topic_ocids" {
  description = "ONS topic(s) that receive the ODB daily spend alarms. Empty = alarms not created."
  type        = list(string)
  default     = []
}

variable "cost_alarm_compartment_name" {
  description = "compartment_name dimension of the spend metrics (the ODB compartment)."
  type        = string
  default     = "111111111111_default-oci-resource-anchor"
}

variable "cost_alarm_daily_threshold" {
  description = "Fixed daily spend (USD) above which the threshold alarm fires. null = no threshold alarm."
  type        = number
  default     = 7000
}

variable "cost_alarm_avg_pct" {
  description = "Fire when a day's spend is above this percent of the previous 30-day average."
  type        = number
  default     = 120
}

locals {
  cost_alarms_enabled = length(var.cost_alarm_topic_ocids) > 0
  cost_alarms = {
    threshold = {
      enabled = local.cost_alarms_enabled && var.cost_alarm_daily_threshold != null
      name    = "odb-daily-spend-above-threshold"
      title   = "ODB daily spend above ${var.cost_alarm_daily_threshold == null ? "" : format("%.0f", var.cost_alarm_daily_threshold)} USD"
      query   = "odb_compartment_daily_cost[1d]{compartment_name = \"${var.cost_alarm_compartment_name}\"}.max() > ${var.cost_alarm_daily_threshold == null ? 0 : var.cost_alarm_daily_threshold}"
      text    = "ODB compartment daily spend is above ${var.cost_alarm_daily_threshold == null ? "" : format("%.0f", var.cost_alarm_daily_threshold)} USD"
    }
    avg = {
      enabled = local.cost_alarms_enabled
      name    = "odb-daily-spend-above-30d-avg"
      title   = "ODB daily spend above ${format("%.0f", var.cost_alarm_avg_pct)}% of 30-day average"
      query   = "odb_compartment_daily_cost_pct_of_30d_avg[1d]{compartment_name = \"${var.cost_alarm_compartment_name}\"}.max() > ${var.cost_alarm_avg_pct}"
      text    = "ODB compartment daily spend is above ${format("%.0f", var.cost_alarm_avg_pct)}% of its previous 30-day average"
    }
  }
}

resource "oci_monitoring_alarm" "odb_spend" {
  for_each = { for k, v in local.cost_alarms : k => v if v.enabled }

  compartment_id        = local.compartment_ocid
  metric_compartment_id = local.compartment_ocid
  namespace             = "example_oracledb_aws"
  display_name          = each.value.name
  query                 = each.value.query
  severity              = "WARNING"
  pending_duration      = "PT1M"
  resolution            = "1m"
  is_enabled            = true
  destinations          = var.cost_alarm_topic_ocids
  message_format        = "ONS_OPTIMIZED"
  notification_title    = each.value.title

  body = <<-EOT
    ${each.value.text} (alarm is "{{status}}"). Daily spend comes from OCI usage data for the ODB compartment ${var.cost_alarm_compartment_name}; see the pdb-cost-report in bucket ocidb-cost-reports-tst (pdb-cost/dev/latest.html) for the per-PDB breakdown.
    ${jsonencode({
  priority         = "P4"
  severity         = "WARNING"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "odb-compartment-${var.cost_alarm_compartment_name}"
  source_hostname  = "oci-cost"
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
})}
  EOT

freeform_tags = merge(var.tags, { metric = "odb_compartment_daily_cost", alarm = each.key })
}
