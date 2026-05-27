locals {
  # Disable actions when in downtime
  alarm_actions_enabled = !var.in_downtime
}

#Disabled Because of 200 Metric alarm Query per AWS account
/*
resource "aws_cloudwatch_metric_alarm" "pdb_Tablespace_space_utilization_warning" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-pdb-Tablespace_space_utilization_warn"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods        = 1
  threshold                 = 75
  treat_missing_data        = "ignore"
  unit                      = null
  metric_query {
    account_id  = null
    expression  = "SELECT MAX(StorageUtilizationByTablespace) FROM \"AWS/ODB\" WHERE resourceId = '${var.database_ocid}'"
    id          = "q1"
    label       = "StorageUtilizationByTablespace"
    period      = 300
    return_data = true
  }
}
*/

#This is a Metric Query, counts against 200 Metric Alarm query limit
resource "aws_cloudwatch_metric_alarm" "pdb_Tablespace_space_utilization_warn" {
  count               = alltrue([var.alarms_enabled, var.is_enabled_pdb_tablespace_utilization_warning]) ? 1 : 0
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-pdb-Tablespace_space_utilization_warn"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  threshold           = 85
  treat_missing_data  = "ignore"
  unit                = null
  metric_query {
    account_id  = null
    expression  = "SELECT MAX(StorageUtilizationByTablespace) FROM \"AWS/ODB\" WHERE resourceId = '${var.database_ocid}'"
    id          = "q1"
    label       = "StorageUtilizationByTablespace"
    period      = 300
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "pdb_Tablespace_space_utilization_crit" {
  count               = var.alarms_enabled ? (var.is_enabled_pdb_tablespace_utilization_critical ? 1 : 0) : 0
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                         {"priority":"P3",
                         "severity":"CRITICAL",
                         "entity":"${var.vm_cluster_name}-${var.database_name}",
                         "environment":"${var.environment}",
                         "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-pdb-Tablespace_space_utilization_warn"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  threshold           = 90
  treat_missing_data  = "ignore"
  unit                = null
  metric_query {
    account_id  = null
    expression  = "SELECT MAX(StorageUtilizationByTablespace) FROM \"AWS/ODB\" WHERE resourceId = '${var.database_ocid}'"
    id          = "q1"
    label       = "StorageUtilizationByTablespace"
    period      = 300
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "pdb_storage_utilization_warning" {
  count               = alltrue([var.alarms_enabled, var.is_enabled_pdb_storage_utilization_warning]) ? 1 : 0
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                         EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-pdb-storage_utilization_warn"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  threshold           = 85
  treat_missing_data  = "ignore"
  unit                = null
  dimensions = {
    cloudExadataInfrastructureId = var.exainfra_id,
    cloudVmClusterId             = var.vm_cluster_id,
    deploymentType               = "EXADATA",

    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.database_ocid,
    resourceName                    = var.database_name,
    resourceType                    = "PDB"
  }
  metric_name = "StorageUtilization"
  namespace   = "AWS/ODB"
  statistic   = "Maximum"
  period      = 3600 # Set to 1 hour as this is intermittent
}

resource "aws_cloudwatch_metric_alarm" "pdb_storage_utilization_critical" {
  count               = alltrue([var.alarms_enabled, var.is_enabled_pdb_storage_utilization_critical]) ? 1 : 0
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"CRITICAL",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                         EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-pdb-storage_utilization_crit"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  threshold           = 90
  treat_missing_data  = "ignore"
  unit                = null
  dimensions = {
    cloudExadataInfrastructureId = var.exainfra_id,
    cloudVmClusterId             = var.vm_cluster_id,
    deploymentType               = "EXADATA",

    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.database_ocid,
    resourceName                    = var.database_name,
    resourceType                    = "PDB"
  }
  metric_name = "StorageUtilization"
  namespace   = "AWS/ODB"
  statistic   = "Maximum"
  period      = 3600 # Set to 1 hour as this is intermittent

}

#Metric Not reporting to Cloudwatch for PDBs
/*
resource "aws_cloudwatch_metric_alarm" "pdb_processes_utilization" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"CRITICAL",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-pdb-process_utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods        = 5
  threshold                 = 80
  treat_missing_data        = "ignore"
  unit                      = null
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "EXADATA",

    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.database_ocid,
    resourceName                    = var.database_name,
    resourceType                    = "PDB"
  }
  metric_name               = "ProcessLimitUtilization"
  namespace                 = "AWS/ODB"
  statistic                 = "Maximum"
  period                   = 300
}
*/

resource "aws_cloudwatch_metric_alarm" "pdb_Monitoring_user_password_expiration_critical" {
  count               = alltrue([var.alarms_enabled, var.is_enabled_pdb_user_password_expiration_critical]) ? 1 : 0
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"CRITICAL",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                         EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-pdb-user_password_expiration_crit"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  threshold           = 3
  treat_missing_data  = "ignore"
  unit                = null
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "EXADATA",
    isPerpetual                     = "Y"
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.database_ocid,
    resourceName                    = var.database_name,
    resourceType                    = "PDB"
  }
  metric_name = "MonitoringUserPasswordExpiration"
  namespace   = "AWS/ODB"
  statistic   = "Sum"
  period      = 3600
}

resource "aws_cloudwatch_metric_alarm" "pdb_Monitoring_user_password_expiration_warning" {
  count               = alltrue([var.alarms_enabled, var.is_enabled_pdb_user_password_expiration_warning]) ? 1 : 0
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                         {"priority":"P4",
                         "severity":"WARNING",
                         "entity":"${var.vm_cluster_name}-${var.database_name}",
                         "environment":"${var.environment}",
                         "source":"Cloudwatch"}
                          EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-pdb-user_password_expiration_warn"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  threshold           = 7
  treat_missing_data  = "ignore"
  unit                = null
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "EXADATA",
    isPerpetual                     = "Y"
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.database_ocid,
    resourceName                    = var.database_name,
    resourceType                    = "PDB"
  }
  metric_name = "MonitoringUserPasswordExpiration"
  namespace   = "AWS/ODB"
  statistic   = "Sum"
  period      = 3600
}

#Requires Metric Query
/*
resource "aws_cloudwatch_metric_alarm" "pdb_CPU_utilization" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"CRITICAL",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-pdb-cpu_utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods        = 2
  threshold                 = 80
  treat_missing_data        = "ignore"
  unit                      = null
  metric_query {
    account_id  = null
    expression  = "SELECT MAX(CPUUtilization) FROM \"AWS/ODB\" WHERE resourceId = '${var.database_ocid}'"
    id          = "q1"
    label       = "CPUUtilization"
    period      = 60
    return_data = true
  }
}
*/

resource "aws_cloudwatch_metric_alarm" "pdb_monitor_status" {
  count               = alltrue([var.alarms_enabled, var.is_enabled_pdb_monitor_status]) ? 1 : 0
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                         EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-pdb_monitor_status"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  threshold           = 1
  treat_missing_data  = "missing"
  unit                = null
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    collectionName                  = "sensor"
    deploymentType                  = "EXADATA",
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.database_ocid,
    resourceName                    = var.database_name,
    resourceType                    = "PDB"
  }
  metric_name = "MonitoringStatus"
  namespace   = "AWS/ODB"
  statistic   = "Sum"
  period      = 300
}

#This check works on OCI but metric does not carry over to Cloudwatch
#Update: Not every PDB reports BlockingSessions
/*
resource "aws_cloudwatch_metric_alarm" "pdb_blocking_sessions_count" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                          EOT
   alarm_actions       = [var.sns_alert_arn]
   ok_actions          = [var.sns_alert_arn]
   alarm_name          = "${var.vm_cluster_name}-${var.database_name}-pdb-blocking_sessions_count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods        = 1
  threshold                 = 0
  treat_missing_data        = "notBreaching"
  unit                      = null
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "EXADATA",

    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.database_ocid,
    resourceName                    = var.database_name,
    resourceType                    = "PDB"
  }
  metric_name               = "BlockingSessions"
  namespace                 = "AWS/ODB"
  statistic                 = "Sum"
  period                    = 300 # Set to 1 hour as this is intermittent
}
*/
