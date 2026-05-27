locals {
  # Disable alarms when in downtime
  alarm_is_enabled = tostring(alltrue([var.alarms_enabled, !var.in_downtime]))
}

resource "oci_monitoring_alarm" "pdb_Tablespace_space_utilization" {
  count = alltrue([var.alarms_enabled, var.is_enabled_pdb_tablespace_utilization]) ? 1 : 0

  body                      = "Tablespace space utilization (%) alarm is \"{{status}}\" for database \"{{dimensions.resourceName}}\" type \"{{dimensions.resourceType}}\" tablespace \"{{dimensions.tablespaceName}}\"."
  compartment_id            = var.compartment_ocid
  destinations              = var.destinations
  display_name              = "${var.vm_cluster_name}-${var.database_name}-pdb-Tablespace_space_utilization"
  evaluation_slack_duration = "PT3M"

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
    body      = "Tablespace space utilization (%) threshold over 90% alarm is \"{{status}}\" for database \"{{dimensions.resourceName}}\" type \"{{dimensions.resourceType}}\" tablespace \"{{dimensions.tablespaceName}}\"."
    query     = "StorageUtilizationByTablespace[1h]{resourceId = \"${var.database_ocid}\"}.mean() > 90"
    rule_name = "critical_rule"
    severity  = "CRITICAL"
  }
}

resource "oci_monitoring_alarm" "pdb_Storage_utilization" {
  count = alltrue([var.alarms_enabled, var.is_enabled_pdb_storage_utilization]) ? 1 : 0

  body                      = "Storage utilization (%) alarm is \"{{status}}\" for database \"{{dimensions.resourceName}}\" type \"{{dimensions.resourceType}}\"."
  compartment_id            = var.compartment_ocid
  destinations              = var.destinations
  display_name              = "${var.vm_cluster_name}-${var.database_name}-pdb-Storage_utilization"
  evaluation_slack_duration = "PT3M"

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
    body      = "Storage utilization (%) threshold over 90% alarm is \"{{status}}\" for database \"{{dimensions.resourceName}}\" type \"{{dimensions.resourceType}}\"."
    query     = "StorageUtilization[1h]{resourceId = \"${var.database_ocid}\"}.mean() > 90"
    rule_name = "critical_rule"
    severity  = "CRITICAL"
  }
}

resource "oci_monitoring_alarm" "pdb_Processes_utilization" {
  count = alltrue([var.alarms_enabled, var.is_enabled_pdb_processes_utilization]) ? 1 : 0

  body                      = "Processes utilization (%) threshold over 80% alarm is \"{{status}}\" for database \"{{dimensions.resourceName}}\" type \"{{dimensions.resourceType}}\"."
  compartment_id            = var.compartment_ocid
  destinations              = var.destinations
  display_name              = "${var.vm_cluster_name}-${var.database_name}-pdb-Process_utilization"
  evaluation_slack_duration = "PT3M"

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

resource "oci_monitoring_alarm" "pdb_Monitoring_user_password_expiration" {
  count = alltrue([var.alarms_enabled, var.is_enabled_pdb_user_password_expiration]) ? 1 : 0

  body                      = "Database user password configured for monitoring \"{{dimensions.resourceName}}\" will expire in less than 7 days. When changing the database user password, you must create a new version of the Vault service secret that contained the old password and update it with the new one."
  compartment_id            = var.compartment_ocid
  destinations              = var.destinations
  display_name              = "${var.vm_cluster_name}-${var.database_name}-pdb-user_password_expiration"
  evaluation_slack_duration = "PT3M"

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
    body      = "Database user password configured for monitoring \"{{dimensions.resourceName}}\" will expire in less than 3 days. When changing the database user password, you must create a new version of the Vault service secret that contained the old password and update it with the new one."
    query     = "MonitoringUserPasswordExpiration[1d]{resourceId = \"${var.database_ocid}\"}.last() <= 3"
    rule_name = "critical_rule"
    severity  = "CRITICAL"
  }
}

resource "oci_monitoring_alarm" "pdb_CPU_utilization" {
  count = alltrue([var.alarms_enabled, var.is_enabled_pdb_cpu_utilization]) ? 1 : 0

  body                      = "Average CPU utilization (%) threshold over 90% alarm is \"{{status}}\" for database \"{{dimensions.resourceName}}\" type \"{{dimensions.resourceType}}\"."
  compartment_id            = var.compartment_ocid
  destinations              = var.destinations
  display_name              = "${var.vm_cluster_name}-${var.database_name}-pdb-cpu_utilization"
  evaluation_slack_duration = "PT3M"

  is_enabled                                    = local.alarm_is_enabled
  is_notifications_per_metric_dimension_enabled = "false"
  message_format                                = "ONS_OPTIMIZED"
  metric_compartment_id                         = var.compartment_ocid
  metric_compartment_id_in_subtree              = "false"
  namespace                                     = "oracle_oci_database"
  notification_title                            = "CPU utilization (%)"
  notification_version                          = "1.X"
  pending_duration                              = "PT5M"
  query                                         = "CpuUtilization[5m]{resourceId = \"${var.database_ocid}\"}.mean() > 90"
  resolution                                    = "1m"
  rule_name                                     = "base"
  severity                                      = "CRITICAL"
}

resource "oci_monitoring_alarm" "pdb_Blocking_sessions_count" {
  count = alltrue([var.alarms_enabled, var.is_enabled_pdb_blocking_sessions_count]) ? 1 : 0

  body                      = "Blocking sessions count for database \"{{dimensions.resourceName}}\" type \"{{dimensions.resourceType}}\" are over 10 for the past 15 minutes."
  compartment_id            = var.compartment_ocid
  destinations              = var.destinations
  display_name              = "${var.vm_cluster_name}-${var.database_name}-pdb-blocking_sessions_count"
  evaluation_slack_duration = "PT3M"

  is_enabled                                    = local.alarm_is_enabled
  is_notifications_per_metric_dimension_enabled = "false"
  message_format                                = "ONS_OPTIMIZED"
  metric_compartment_id                         = var.compartment_ocid
  metric_compartment_id_in_subtree              = "false"
  namespace                                     = "oracle_oci_database"
  notification_title                            = "Blocking sessions count"
  notification_version                          = "1.X"
  pending_duration                              = "PT1M"
  query                                         = "BlockingSessions[30m]{resourceId = \"${var.database_ocid}\"}.mean() > 10"
  resolution                                    = "1m"
  rule_name                                     = "base"
  severity                                      = "CRITICAL"
}
