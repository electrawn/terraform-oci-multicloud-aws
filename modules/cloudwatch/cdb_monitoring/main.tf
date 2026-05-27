locals {
  # Disable actions when in downtime
  alarm_actions_enabled = !var.in_downtime
}

/*
resource "aws_cloudwatch_metric_alarm" "System_Perm_StorageUtilizationByTablespace" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"CRITICAL",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
   alarm_actions       = [var.sns_alert_arn]
   ok_actions          = [var.sns_alert_arn]
   alarm_name          = "${var.vm_cluster_name}-${var.database_name}-StorageUtilizationByTablespace-system-perm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  dimensions = {
    cloudVmClusterId                = var.vm_cluster_id,
    cloudExadataInfrastructureId    = var.exainfra_id,
    deploymentType                  = "exadata",
    resourceName                    = var.vm_cluster_name
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceId_database             = var.database_ocid #"ocid1.database.oc1.iad.anuwcljsyimjr2yak5xawggxviywgqslohz5agzvshkbcioxnso2sznzsf6q"
    resourceName_database           = var.database_name #"tstcdb"
    tablespaceName                  = "system"
    tablespaceType                  = "permanent"
  }
  evaluation_periods        = 1
  extended_statistic        = null
  insufficient_data_actions = []
  metric_name               = "StorageUtilizationByTablespace"
  namespace                 = "AWS/ODB"
  ok_actions                = []
  period                    = 3600 # Set to 1 hour as this is intermittent
  statistic                 = "Average"

  treat_missing_data        = "ignore" #Set as reporting is intermittent
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "Sysaux_Perm_StorageUtilizationByTablespace" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"CRITICAL",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
   alarm_actions       = [var.sns_alert_arn]
   ok_actions          = [var.sns_alert_arn]
   alarm_name          = "${var.vm_cluster_name}-${var.database_name}-StorageUtilizationByTablespace-sysaux-perm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  dimensions = {
    cloudVmClusterId                = var.vm_cluster_id,
    cloudExadataInfrastructureId    = var.exainfra_id,
    deploymentType                  = "exadata",
    resourceName                    = var.vm_cluster_name
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceId_database             = var.database_ocid #"ocid1.database.oc1.iad.anuwcljsyimjr2yak5xawggxviywgqslohz5agzvshkbcioxnso2sznzsf6q"
    resourceName_database           = var.database_name #"tstcdb"
    tablespaceName                  = "sysaux"
    tablespaceType                  = "permanent"
  }
  evaluation_periods        = 1
  extended_statistic        = null
  insufficient_data_actions = []
  metric_name               = "StorageUtilizationByTablespace"
  namespace                 = "AWS/ODB"
  ok_actions                = []
  period                    = 3600 # Set to 1 hour as this is intermittent
  statistic                 = "Average"
  tags                      = {}

resource "aws_cloudwatch_metric_alarm" "Users_Perm_StorageUtilizationByTablespace" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"CRITICAL",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
   alarm_actions       = [var.sns_alert_arn]
   ok_actions          = [var.sns_alert_arn]
   alarm_name          = "${var.vm_cluster_name}-${var.database_name}-StorageUtilizationByTablespace-users-perm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  dimensions = {
    cloudVmClusterId                = var.vm_cluster_id,
    cloudExadataInfrastructureId    = var.exainfra_id,
    deploymentType                  = "exadata",
    resourceName                    = var.vm_cluster_name
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceId_database             = var.database_ocid #"ocid1.database.oc1.iad.anuwcljsyimjr2yak5xawggxviywgqslohz5agzvshkbcioxnso2sznzsf6q"
    resourceName_database           = var.database_name #"tstcdb"
    tablespaceName                  = "users"
    tablespaceType                  = "permanent"
  }
  evaluation_periods        = 1
  extended_statistic        = null
  insufficient_data_actions = []
  metric_name               = "StorageUtilizationByTablespace"
  namespace                 = "AWS/ODB"
  ok_actions                = []
  period                    = 3600 # Set to 1 hour as this is intermittent
  statistic                 = "Average"
  tags                      = {}
*/

#Disabled, Metric Query monitored at PDB level
/*
resource "aws_cloudwatch_metric_alarm" "cdb_Tablespace_space_utilization_warning" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"CRITICAL",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                         EOT
   alarm_actions       = [var.sns_alert_arn]
   ok_actions          = [var.sns_alert_arn]
   alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb-Tablespace_space_utilization_warn"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods        = 1
  threshold                 = 75
  treat_missing_data        = "ignore"
  unit                      = null
  metric_query {
    account_id  = null
    expression  = "SELECT MAX(StorageUtilizationByTablespace) FROM \"AWS/ODB\" WHERE resourceId_database = '${var.database_ocid}'"
    id          = "q1"
    label       = "StorageUtilizationByTablespace"
    period      = 300
    return_data = true
  }
}
*/

#Disabled, Metric Query Monitored at PDB
/*
resource "aws_cloudwatch_metric_alarm" "cdb_Tablespace_space_utilization_critical" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"CRITICAL",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                         EOT
   alarm_actions       = [var.sns_alert_arn]
   ok_actions          = [var.sns_alert_arn]
   alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb-Tablespace_space_utilization_crit"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods        = 1
  threshold                 = 85
  treat_missing_data        = "ignore"
  unit                      = null
  metric_query {
    account_id  = null
    expression  = "SELECT MAX(StorageUtilizationByTablespace) FROM \"AWS/ODB\" WHERE resourceId_database = '${var.database_ocid}'"
    id          = "q1"
    label       = "StorageUtilizationByTablespace"
    period      = 300
    return_data = true
  }
}
*/

resource "aws_cloudwatch_metric_alarm" "cdb_storage_utilization_warning" {
  count               = alltrue([var.alarms_enabled, var.is_enabled_cdb_storage_utilization_warning]) ? 1 : 0
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
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb-storage_utilization_warn"
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
    resourceType                    = "CDB"
  }
  metric_name = "StorageUtilization"
  namespace   = "AWS/ODB"
  statistic   = "Maximum"
  period      = 3600 # Set to 1 hour as this is intermittent

}

resource "aws_cloudwatch_metric_alarm" "cdb_storage_utilization_critical" {
  count               = alltrue([var.alarms_enabled, var.is_enabled_cdb_storage_utilization_critical]) ? 1 : 0
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
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb-storage_utilization_crit"
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
    resourceType                    = "CDB"
  }
  metric_name = "StorageUtilization"
  namespace   = "AWS/ODB"
  statistic   = "Maximum"
  period      = 3600 # Set to 1 hour as this is intermittent

}

#Another Metric Query, May have to remove.
resource "aws_cloudwatch_metric_alarm" "cdb_processes_utilization" {
  count               = alltrue([var.alarms_enabled, var.is_enabled_cdb_processes_utilization]) ? 1 : 0
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
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb-process_utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 5
  threshold           = 80
  treat_missing_data  = "ignore"
  unit                = null
  metric_query {
    account_id  = null
    expression  = "SELECT AVG(ProcessLimitUtilization) FROM \"AWS/ODB\" WHERE resourceId = '${var.database_ocid}' "
    id          = "q1"
    label       = "ProcessLimitUtilization"
    period      = 60
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "cdb_Monitoring_user_password_expiration_critical" {
  count               = alltrue([var.alarms_enabled, var.is_enabled_cdb_user_password_expiration_critical]) ? 1 : 0
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
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb-user_password_expiration_crit"
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
    resourceType                    = "CDB"
  }
  metric_name = "MonitoringUserPasswordExpiration"
  namespace   = "AWS/ODB"
  statistic   = "Sum"
  period      = 3600
}

resource "aws_cloudwatch_metric_alarm" "cdb_Monitoring_user_password_expiration_warning" {
  count               = alltrue([var.alarms_enabled, var.is_enabled_cdb_user_password_expiration_warning]) ? 1 : 0
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
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb-user_password_expiration_warn"
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
    resourceType                    = "CDB"
  }
  metric_name = "MonitoringUserPasswordExpiration"
  namespace   = "AWS/ODB"
  statistic   = "Sum"
  period      = 3600
}
#Requires Metric Query, Disabled
/*
resource "aws_cloudwatch_metric_alarm" "cdb_CPU_utilization" {
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
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb-cpu_utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods        = 5
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

resource "aws_cloudwatch_metric_alarm" "cdb_monitor_status" {
  count               = alltrue([var.alarms_enabled, var.is_enabled_cdb_monitor_status]) ? 1 : 0
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
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb_monitor_status"
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
    resourceType                    = "CDB"
  }
  metric_name = "MonitoringStatus"
  namespace   = "AWS/ODB"
  statistic   = "Sum"
  period      = 300
}

/*
resource "aws_cloudwatch_metric_alarm" "cdb_flash_recovery_area_utilization" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions = [var.sns_alert_arn]
  ok_actions    = [var.sns_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb-flash_recovery_utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 5
  threshold           = 75
  treat_missing_data  = "ignore"
  unit                = null
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "EXADATA",

    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.database_ocid,
    resourceName                    = var.database_name,
    resourceType                    = "CDB"
  }
  metric_name               = "FRAUtilization"
  namespace                 = "AWS/ODB"
  statistic                 = "Average"
  period                    = 300
}
 */
#Disabled Because of 200 Metric alarm Query per AWS account

