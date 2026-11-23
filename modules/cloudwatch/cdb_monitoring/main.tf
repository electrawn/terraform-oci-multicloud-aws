locals {
  # Disable actions when in downtime
  alarm_actions_enabled = !var.in_downtime
}

/*
resource "aws_cloudwatch_metric_alarm" "System_Perm_StorageUtilizationByTablespace" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        This metric monitors CDB Tablespace System Storage Utilization for ${var.environment} environment of ${var.database_name}
                        {"priority":"P3",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"https://wiki.example.com/docs/page-001"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
    resourceId_database             = var.database_ocid #"ocid1.database.oc1.iad.exampleuniqueiddataba0001"
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
  tags = {
    managed_by  = "terraform",
    created_by  = var.tag_created_by,
    Team        = var.tag_team,
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "Sysaux_Perm_StorageUtilizationByTablespace" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        This metric monitors CDB Tablespace Sysaux Storage Utilization for ${var.environment} environment of ${var.database_name}
                        {"priority":"P3",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"https://wiki.example.com/docs/page-001"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
    resourceId_database             = var.database_ocid #"ocid1.database.oc1.iad.exampleuniqueiddataba0001"
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
  tags_all                  = {}
  treat_missing_data        = "ignore" #Set as reporting is intermittent
}

resource "aws_cloudwatch_metric_alarm" "Users_Perm_StorageUtilizationByTablespace" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        This metric monitors CDB Tablespace Users Storage Utilization for ${var.environment} environment of ${var.database_name}
                        {"priority":"P3",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"https://wiki.example.com/docs/page-001"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
    resourceId_database             = var.database_ocid #"ocid1.database.oc1.iad.exampleuniqueiddataba0001"
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
  tags_all                  = {}
  treat_missing_data        = "ignore" #Set as reporting is intermittent
}
*/

#Disabled, Metric Query monitored at PDB level
/*
resource "aws_cloudwatch_metric_alarm" "cdb_Tablespace_space_utilization_warning" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        This metric monitors cdb Tablespace Utilization via Metric Query for ${var.environment} environment of ${var.database_name}
                        {"priority":"P3",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"https://wiki.example.com/docs/page-001"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
                        This metric monitors cdb User Password Expiration via Metric Query for ${var.environment} environment of ${var.database_name}
                        {"priority":"P3",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"https://wiki.example.com/docs/page-001"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
                        This metric monitors cdb Storage Utilization via Metric Query for ${var.environment} environment of ${var.database_name}
                        {"priority":"P4",
                        "severity":"WARNING",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"https://wiki.example.com/docs/page-002"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
                        This metric monitors cdb Storage Utilization via Metric Query for ${var.environment} environment of ${var.database_name}
                        {"priority":"P4",
                        "severity":"CRITICAL",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"https://wiki.example.com/docs/page-002"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
                        This metric monitors cdb Process Utilization via Metric Query for ${var.environment} environment of ${var.database_name}
                        {"priority":"P4",
                        "severity":"CRITICAL",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"${var.docs_link}"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
                        This metric monitors cdb User Password Expiration via Metric Query for ${var.environment} environment of ${var.database_name}
                        {"priority":"P4",
                        "severity":"CRITICAL",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"https://wiki.example.com/docs/page-003"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
                        This metric monitors cdb User Password Expiration via Metric Query for ${var.environment} environment of ${var.database_name}
                        {"priority":"P4",
                        "severity":"CRITICAL",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"https://wiki.example.com/docs/page-003"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
                        This metric monitors cdb CPU Utilization via Metric Query for ${var.environment} environment of ${var.database_name}
                        {"priority":"P4",
                        "severity":"WARNING",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"${var.docs_link}"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
                        This metric monitors cdb Monitor Status via Metric Query for ${var.environment} environment of ${var.database_name}
                        {"priority":"P4",
                         "severity":"WARNING",
                         "noc_bypass":"true",
                         "noc_desk":"DB Services",
                         "downtime":"${var.in_downtime}",
                         "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"https://wiki.example.com/docs/page-004"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb_monitor_status"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 3
  evaluation_periods  = 3
  threshold           = 1
  # Treat missing data as breaching: if the CDB stops reporting MonitoringStatus
  # we assume the service is down. With period=300s, 3 evaluation periods require
  # 15 continuous minutes of no data before the alarm fires (pages OpsGenie).
  treat_missing_data = "breaching"
  unit               = null
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

/* Disabled again after 6/3/26, monitor reco1 and data1 at cluster
resource "aws_cloudwatch_metric_alarm" "cdb_flash_recovery_area_utilization_warning" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        This metric monitors cdb Flash Recovery Area Utilization via Metric Query for ${var.environment} environment of ${var.database_name}
                        {"priority":"P4",
                        "severity":"WARNING",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"https://wiki.example.com/docs/page-005"}
                        EOT
  alarm_actions = [var.opsgenie_alert_arn]
  ok_actions    = [var.opsgenie_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb-flash_recovery_utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 5
  threshold           = 80
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

resource "aws_cloudwatch_metric_alarm" "cdb_flash_recovery_area_utilization_critical" {
  actions_enabled     = true
  alarm_description   = <<-EOT
                        This metric monitors cdb Flash Recovery Area Utilization via Metric Query for ${var.environment} environment of ${var.database_name}
                        {"priority":"P4",
                        "severity":"CRITICAL",
                        "noc_bypass":"true",
                        "noc_desk":"DB Services",
                        "downtime":"${var.in_downtime}",
                        "environment":"${var.environment}",
                        "entity":"${var.vm_cluster_name}-${var.database_name}",
                        "source_hostname":"${var.vm_cluster_name}",
                        "source_uid":"${var.vm_cluster_ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"https://wiki.example.com/docs/page-005"}
                        EOT
  alarm_actions = [var.opsgenie_alert_arn]
  ok_actions    = [var.opsgenie_alert_arn]
  alarm_name          = "${var.vm_cluster_name}-${var.database_name}-cdb-flash_recovery_utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 5
  threshold           = 90
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

