locals {
  # Disable alarms when in downtime
  alarm_is_enabled = tostring(alltrue([var.ocimon_alarms_enabled, !var.in_downtime]))
}

resource "oci_monitoring_alarm" "cdb_Tablespace_space_utilization" {
  count = alltrue([var.ocimon_alarms_enabled, var.is_enabled_ocimon_cdb_tablespace_utilization]) ? 1 : 0

  body = <<-EOT
                                                Tablespace space utilization (%) alarm is "{{status}}" for database "{{dimensions.resourceName}}" type "{{dimensions.resourceType}}" tablespace "{{dimensions.tablespaceName}}".
                                                ${jsonencode({
  priority         = "P4"
  severity         = "WARNING"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = "https://wiki.example.com/docs/page-001"
})}
                                                EOT
compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${var.database_name}-cdb-Tablespace_space_utilization"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = var.tags
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "true"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = "oracle_oci_database"
notification_title                            = "Tablespace space utilization (%)"
notification_version                          = "1.X"
pending_duration                              = "PT1M"
query                                         = "StorageUtilizationByTablespace[1h]{resourceId = \"${var.database_ocid}\"}.mean() > 85"
resolution                                    = "1m"
rule_name                                     = "warning_rule"
severity                                      = "WARNING"

overrides {
  body = <<-EOT
                                                Tablespace space utilization (%) threshold over 90% alarm is "{{status}}" for database "{{dimensions.resourceName}}" type "{{dimensions.resourceType}}" tablespace "{{dimensions.tablespaceName}}".
                                                ${jsonencode({
  priority         = "P3"
  severity         = "CRITICAL"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = "https://wiki.example.com/docs/page-001"
})}
                                                EOT
query     = "StorageUtilizationByTablespace[1h]{resourceId = \"${var.database_ocid}\"}.mean() > 90"
rule_name = "critical_rule"
severity  = "CRITICAL"
}
}

resource "oci_monitoring_alarm" "cdb_Storage_utilization" {
  count = alltrue([var.ocimon_alarms_enabled, var.is_enabled_ocimon_cdb_storage_utilization]) ? 1 : 0

  body = <<-EOT
                                                Storage utilization (%) alarm is "{{status}}" for database "{{dimensions.resourceName}}" type "{{dimensions.resourceType}}".
                                                ${jsonencode({
  priority         = "P4"
  severity         = "WARNING"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = "https://wiki.example.com/docs/page-002"
})}
                                                EOT
compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${var.database_name}-cdb-Storage_utilization"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = var.tags
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "false"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = "oracle_oci_database"
notification_title                            = "Storage utilization (%)"
notification_version                          = "1.X"
pending_duration                              = "PT1M"
query                                         = "StorageUtilization[1h]{resourceId = \"${var.database_ocid}\"}.mean() > 85"
resolution                                    = "1m"
rule_name                                     = "warning_rule"
severity                                      = "WARNING"

overrides {
  body = <<-EOT
                                                Storage utilization (%) threshold over 90% alarm is "{{status}}" for database "{{dimensions.resourceName}}" type "{{dimensions.resourceType}}".
                                                ${jsonencode({
  priority         = "P4"
  severity         = "CRITICAL"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = "https://wiki.example.com/docs/page-002"
})}
                                                EOT
query     = "StorageUtilization[1h]{resourceId = \"${var.database_ocid}\"}.mean() > 90"
rule_name = "critical_rule"
severity  = "CRITICAL"
}
}

resource "oci_monitoring_alarm" "cdb_Processes_utilization" {
  count = alltrue([var.ocimon_alarms_enabled, var.is_enabled_ocimon_cdb_processes_utilization]) ? 1 : 0

  body = <<-EOT
                                                Processes utilization (%) threshold over 80% alarm is "{{status}}" for database "{{dimensions.resourceName}}" type "{{dimensions.resourceType}}".
                                                ${jsonencode({
  priority         = "P4"
  severity         = "CRITICAL"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.docs_link
})}
                                                EOT
compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${var.database_name}-cdb-Process_utilization"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = var.tags
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "false"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = "oracle_oci_database"
notification_title                            = "Processes utilization (%)"
notification_version                          = "1.X"
pending_duration                              = "PT5M"
query                                         = "ProcessLimitUtilization[5m]{resourceId = \"${var.database_ocid}\"}.mean() > 80"
resolution                                    = "1m"
rule_name                                     = "base"
severity                                      = "CRITICAL"
}

resource "oci_monitoring_alarm" "cdb_Monitoring_user_password_expiration" {
  count = alltrue([var.ocimon_alarms_enabled, var.is_enabled_ocimon_cdb_user_password_expiration]) ? 1 : 0

  body = <<-EOT
                                                Database user password configured for monitoring "{{dimensions.resourceName}}" will expire in less than 7 days. When changing the database user password, you must create a new version of the Vault service secret that contained the old password and update it with the new one.
                                                ${jsonencode({
  priority         = "P4"
  severity         = "CRITICAL"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = "https://wiki.example.com/docs/page-003"
})}
                                                EOT
compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${var.database_name}-cdb-user_password_expiration"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = var.tags
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "false"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = "oracle_oci_database"
notification_title                            = "Monitoring user password expiration"
notification_version                          = "1.X"
pending_duration                              = "PT1H"
query                                         = "MonitoringUserPasswordExpiration[1d]{resourceId = \"${var.database_ocid}\"}.last() <= 7"
resolution                                    = "1m"
rule_name                                     = "warning_rule"
severity                                      = "WARNING"

overrides {
  body = <<-EOT
                                                Database user password configured for monitoring "{{dimensions.resourceName}}" will expire in less than 3 days. When changing the database user password, you must create a new version of the Vault service secret that contained the old password and update it with the new one.
                                                ${jsonencode({
  priority         = "P4"
  severity         = "CRITICAL"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = "https://wiki.example.com/docs/page-003"
})}
                                                EOT
query     = "MonitoringUserPasswordExpiration[1d]{resourceId = \"${var.database_ocid}\"}.last() <= 3"
rule_name = "critical_rule"
severity  = "CRITICAL"
}
}

resource "oci_monitoring_alarm" "cdb_CPU_utilization" {
  count = alltrue([var.ocimon_alarms_enabled, var.is_enabled_ocimon_cdb_cpu_utilization]) ? 1 : 0

  body = <<-EOT
                                                Average CPU utilization (%) threshold over 90% alarm is "{{status}}" for database "{{dimensions.resourceName}}" type "{{dimensions.resourceType}}".
                                                ${jsonencode({
  priority         = "P4"
  severity         = "CRITICAL"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.docs_link
})}
                                                EOT
compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${var.database_name}-cdb-cpu_utilization"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = var.tags
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "false"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = "oracle_oci_database"
resource_group                                = "oracle_dataguard"
notification_title                            = "CPU utilization (%)"
notification_version                          = "1.X"
pending_duration                              = "PT5M"
query                                         = "CpuUtilization[5m]{resourceId = \"${var.database_ocid}\"}.mean() > 90"
resolution                                    = "1m"
rule_name                                     = "base"
severity                                      = "CRITICAL"
}

resource "oci_monitoring_alarm" "cdb_Apply_lag" {
  count = alltrue([var.ocimon_alarms_enabled, var.is_enabled_ocimon_cdb_apply_lag]) ? 1 : 0

  body = <<-EOT
                                                Apply lag alarm is "{{status}}" for database "{{dimensions.resourceName}}" type "{{dimensions.resourceType}}".
                                                ${jsonencode({
  priority         = "P4"
  severity         = "WARNING"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.docs_link
})}
                                                EOT
compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${var.database_name}-cdb-apply_lag"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = var.tags
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "false"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = "oracle_oci_database"
resource_group                                = "oracle_dataguard"
notification_title                            = "Apply lag"
notification_version                          = "1.X"
pending_duration                              = "PT5M"
query                                         = "ApplyLag[5m]{resourceName = \"${var.database_name}\"}.mean() > 7200"
resolution                                    = "1m"
rule_name                                     = "warning_rule"
severity                                      = "WARNING"

overrides {
  body = <<-EOT
                                                Apply lag threshold over 10800 alarm is "{{status}}" for database "{{dimensions.resourceName}}" type "{{dimensions.resourceType}}".
                                                ${jsonencode({
  priority         = "P4"
  severity         = "CRITICAL"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.docs_link
})}
                                                EOT
query     = "ApplyLag[1h]{resourceName = \"${var.database_name}\"}.mean() > 10800"
rule_name = "critical_rule"
severity  = "CRITICAL"
}
}

resource "oci_monitoring_alarm" "cdb_Transport_lag" {
  count = alltrue([var.ocimon_alarms_enabled, var.is_enabled_ocimon_cdb_transport_lag]) ? 1 : 0

  body = <<-EOT
                                                Transport lag alarm is "{{status}}" for database "{{dimensions.resourceName}}" type "{{dimensions.resourceType}}".
                                                ${jsonencode({
  priority         = "P4"
  severity         = "WARNING"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.docs_link
})}
                                                EOT
compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${var.database_name}-cdb-transport_lag"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = var.tags
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "false"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = "oracle_oci_database"
resource_group                                = "oracle_dataguard"
notification_title                            = "Transport lag"
notification_version                          = "1.X"
pending_duration                              = "PT5M"
query                                         = "TransportLag[5m]{resourceName = \"${var.database_name}\"}.mean() > 600"
resolution                                    = "1m"
rule_name                                     = "warning_rule"
severity                                      = "WARNING"

overrides {
  body = <<-EOT
                                                Transport lag threshold over 900 alarm is "{{status}}" for database "{{dimensions.resourceName}}" type "{{dimensions.resourceType}}".
                                                ${jsonencode({
  priority         = "P4"
  severity         = "CRITICAL"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.docs_link
})}
                                                EOT
query     = "TransportLag[1h]{resourceName = \"${var.database_name}\"}.mean() > 900"
rule_name = "critical_rule"
severity  = "CRITICAL"
}
}

resource "oci_monitoring_alarm" "cdb_Backup_status_failed" {
  count = alltrue([var.ocimon_alarms_enabled, var.is_enabled_ocimon_cdb_backup_status_failed]) ? 1 : 0

  body = <<-EOT
                                                Backup status failed alarm is "{{status}}" for database "{{dimensions.resourceName}}" type "{{dimensions.resourceType}}".
                                                ${jsonencode({
  priority         = "P3"
  severity         = "CRITICAL"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = "https://wiki.example.com/docs/page-011"
})}
                                                EOT
compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${var.database_name}-cdb-backup_status_failed"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = var.tags
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "false"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = "oracle_oci_database"
notification_title                            = "Backup status failed"
notification_version                          = "1.X"
pending_duration                              = "PT1M"
query                                         = "BackupSize[1d]{resourceId = \"${var.database_ocid}\", status = \"failure\"}.count() > 0"
resolution                                    = "1m"
rule_name                                     = "base"
severity                                      = "CRITICAL"
}

resource "oci_monitoring_alarm" "cdb_Flash_recovery_area_utilization" {
  count = alltrue([var.ocimon_alarms_enabled, var.is_enabled_ocimon_cdb_flash_recovery_area_utilization]) ? 1 : 0

  body = <<-EOT
                                                Flash recovery area utilization (%) threshold over 90% alarm is "{{status}}" for database "{{dimensions.resourceName}}" type "{{dimensions.resourceType}}".
                                                ${jsonencode({
  priority         = "P4"
  severity         = "CRITICAL"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = "https://wiki.example.com/docs/page-005"
})}
                                                EOT
compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${var.database_name}-cdb-flash_recovery_area_utilization"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = var.tags
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "true"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = "oracle_oci_database"
notification_title                            = "Flash recovery area utilization (%)"
notification_version                          = "1.X"
pending_duration                              = "PT1M"
query                                         = "FRAUtilization[30m]{resourceId = \"${var.database_ocid}\"}.mean() > 90"
resolution                                    = "1m"
rule_name                                     = "base"
severity                                      = "CRITICAL"
}

# ---------------------------------------------------------------------------
# ZDLRA — Zero Data Loss Autonomous Recovery Service protected-database health.
#
# Status metric from the `oci_recovery_service` namespace:
#   ProtectedDatabaseHealth  0 = Protected, 1 = Warning (data loss exposure),
#                            2 = Alert (latest backup failed). Statistic Max,
#                            30-minute interval.
#
# Keyed on dBUniqueName (= database name) rather than the protected-database
# OCID, since the per-CDB module does not carry the
# ocid1.recoveryserviceprotecteddatabase... identifier. This mirrors how the
# Data Guard ApplyLag/TransportLag alarms above query by resourceName.
#
# Warning fires at health > 0; a critical override fires at health >= 2
# (failed backup). Harmless until the database is onboarded to Recovery
# Service — the metric simply has no datapoints before then.
# ---------------------------------------------------------------------------
resource "oci_monitoring_alarm" "cdb_Zdlra_backup_status" {
  count = alltrue([var.ocimon_alarms_enabled, var.is_enabled_ocimon_cdb_zdlra_backup_status]) ? 1 : 0

  body = <<-EOT
                                                ZDLRA protected-database health alarm is "{{status}}" for database "{{dimensions.dBUniqueName}}" (0=Protected, 1=Warning, 2=Alert/backup failed).
                                                ${jsonencode({
  priority         = "P4"
  severity         = "WARNING"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.docs_link
})}
                                                EOT
compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${var.database_name}-cdb-zdlra_backup_status"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = var.tags
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "false"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = "oci_recovery_service"
notification_title                            = "ZDLRA protected-database health"
notification_version                          = "1.X"
pending_duration                              = "PT15M"
# ProtectedDatabaseHealth is emitted with the full DB unique name (e.g.
# "CDB065_exa1vmc1"), so match the <database_name>_* prefix, not an exact
# dBUniqueName.
query      = "ProtectedDatabaseHealth[30m]{dBUniqueName =~ \"${var.database_name}_*\"}.max() > 0"
resolution = "1m"
rule_name  = "warning_rule"
severity   = "WARNING"

overrides {
  body = <<-EOT
                                                ZDLRA protected-database latest backup FAILED (health = 2) alarm is "{{status}}" for database "{{dimensions.dBUniqueName}}".
                                                ${jsonencode({
  priority         = "P3"
  severity         = "CRITICAL"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${var.database_name}"
  source_hostname  = var.vm_cluster_name
  source_uid       = var.vm_cluster_ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.docs_link
})}
                                                EOT
query     = "ProtectedDatabaseHealth[30m]{dBUniqueName =~ \"${var.database_name}_*\"}.max() >= 2"
rule_name = "critical_rule"
severity  = "CRITICAL"
}
}
