locals {
  # Transform the list into a map using a for expression
  db_server_map = {
    for db_server in var.aws_exainfra_dbservers.db_servers : db_server.id => db_server
  }
  db_node_map = {
    for node in var.aws_vmcluster_dbnodes.db_nodes : node.db_server_id => node
  }
  # Disable actions when in downtime
  alarm_actions_enabled = !var.in_downtime
}

moved {
  from = aws_cloudwatch_metric_alarm.u01_filesystem_utilization
  to   = aws_cloudwatch_metric_alarm.u01_filesystem_utilization_crit
}

moved {
  from = aws_cloudwatch_metric_alarm.crashfiles_filesystem_utilization
  to   = aws_cloudwatch_metric_alarm.crashfiles_filesystem_utilization_crit
}

moved {
  from = aws_cloudwatch_metric_alarm.var_filesystem_utilization
  to   = aws_cloudwatch_metric_alarm.var_filesystem_utilization_crit
}

moved {
  from = aws_cloudwatch_metric_alarm.boot_filesystem_utilization
  to   = aws_cloudwatch_metric_alarm.boot_filesystem_utilization_crit
}

moved {
  from = aws_cloudwatch_metric_alarm.root_filesystem_utilization
  to   = aws_cloudwatch_metric_alarm.root_filesystem_utilization_crit
}

moved {
  from = aws_cloudwatch_metric_alarm.var_log_audit_filesystem_utilization
  to   = aws_cloudwatch_metric_alarm.var_log_audit_filesystem_utilization_crit
}

moved {
  from = aws_cloudwatch_metric_alarm.home_filesystem_utilization
  to   = aws_cloudwatch_metric_alarm.home_filesystem_utilization_crit
}

moved {
  from = aws_cloudwatch_metric_alarm.acfs01_filesystem_utilization
  to   = aws_cloudwatch_metric_alarm.acfs01_filesystem_utilization_crit
}

moved {
  from = aws_cloudwatch_metric_alarm.u02_filesystem_utilization
  to   = aws_cloudwatch_metric_alarm.u02_filesystem_utilization_crit
}

moved {
  from = aws_cloudwatch_metric_alarm.tmp_filesystem_utilization
  to   = aws_cloudwatch_metric_alarm.tmp_filesystem_utilization_crit
}

moved {
  from = aws_cloudwatch_metric_alarm.u01_app_grid_filesystem_utilization
  to   = aws_cloudwatch_metric_alarm.u01_app_grid_filesystem_utilization_crit
}

moved {
  from = aws_cloudwatch_metric_alarm.var_log_filesystem_utilization
  to   = aws_cloudwatch_metric_alarm.var_log_filesystem_utilization_crit
}

resource "aws_cloudwatch_metric_alarm" "vm_cluster_cpu" {
  #for_each =  data.aws_odb_cloud_vm_cluster.vm_cluster.db_servers
  # for_each            = { for index, db_node in var.aws_vmcluster_dbnodes.db_nodes : db_node.id => db_node /*if db_node.db_server_id == var.db_server_id*/ }
  for_each            = var.is_enabled_vm_cluster_cpu ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-cpu-utilization"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"CRITICAL",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                         EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  datapoints_to_alarm = "2"
  metric_name         = "CpuUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  dimensions = {
    cloudVmClusterId                = var.vm_cluster_id,
    cloudExadataInfrastructureId    = var.exainfra_id,
    deploymentType                  = "exadata",
    hostName                        = local.db_node_map[each.value].hostname,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "vm_cluster_memory" {
  #for_each            = { for index, db_node in var.aws_vmcluster_dbnodes.db_nodes : db_node.id => db_node /*if db_node.db_server_id == var.db_server_id*/ }
  for_each            = var.is_enabled_vm_cluster_memory ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-memory-utilization"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"CRITICAL",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  datapoints_to_alarm = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  dimensions = {
    cloudVmClusterId                = var.vm_cluster_id,
    cloudExadataInfrastructureId    = var.exainfra_id,
    deploymentType                  = "exadata",
    hostName                        = local.db_node_map[each.value].hostname,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
  }
  tags = {}
}


resource "aws_cloudwatch_metric_alarm" "node_status" {
  #for_each            = { for index, db_node in var.aws_vmcluster_dbnodes.db_nodes : db_node.id => db_node /*if db_node.db_server_id == var.db_server_id*/ }
  for_each            = var.is_enabled_node_status ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-node-status"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                         {"priority":"P3",
                         "severity":"Critical",
                         "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                         "environment":"${var.environment}",
                         "source":"Cloudwatch"}
                         EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  datapoints_to_alarm = "2"
  metric_name         = "NodeStatus"
  namespace           = "AWS/ODB"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1" # If 0, node is unreachable
  dimensions = {
    cloudVmClusterId                = var.vm_cluster_id,
    cloudExadataInfrastructureId    = var.exainfra_id,
    deploymentType                  = "exadata",
    hostName                        = local.db_node_map[each.value].hostname,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "u01_filesystem_utilization_crit" {
  #for_each            = { for index, db_node in var.aws_vmcluster_dbnodes.db_nodes : db_node.id => db_node /*if db_node.db_server_id == var.db_server_id*/ }
  for_each            = var.is_enabled_filesystem_utilization_crit && var.is_enabled_u01_filesystem_utilization_crit ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-u01_filesystemutilization_crit"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                         {"priority":"P3",
                         "severity":"Critical",
                         "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                         "environment":"${var.environment}",
                         "source":"Cloudwatch"}
                          EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "90" # If 0, node is unreachable
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/u01",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,


  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "u01_filesystem_utilization_warning" {
  for_each            = var.is_enabled_filesystem_utilization_warning && var.is_enabled_u01_filesystem_utilization_warning ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-u01_filesystemutilization_warn"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "85"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/u01",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "crashfiles_filesystem_utilization_crit" {
  for_each            = var.is_enabled_filesystem_utilization_crit && var.is_enabled_crashfiles_filesystem_utilization_crit ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-crashfiles_filesystemutilization_crit"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"Critical",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "90"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/crashfiles",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "crashfiles_filesystem_utilization_warning" {
  for_each            = var.is_enabled_filesystem_utilization_warning && var.is_enabled_crashfiles_filesystem_utilization_warning ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-crashfiles_filesystemutilization_warn"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "85"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/crashfiles",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "var_filesystem_utilization_crit" {
  for_each            = var.is_enabled_filesystem_utilization_crit && var.is_enabled_var_filesystem_utilization_crit ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-var_filesystemutilization_crit"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"Critical",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "90"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/var",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "var_filesystem_utilization_warning" {
  for_each            = var.is_enabled_filesystem_utilization_warning && var.is_enabled_var_filesystem_utilization_warning ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-var_filesystemutilization_warn"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "85"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/var",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "boot_filesystem_utilization_crit" {
  for_each            = var.is_enabled_filesystem_utilization_crit && var.is_enabled_boot_filesystem_utilization_crit ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-boot_filesystemutilization_crit"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"Critical",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "90"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/boot",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "boot_filesystem_utilization_warning" {
  for_each            = var.is_enabled_filesystem_utilization_warning && var.is_enabled_boot_filesystem_utilization_warning ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-boot_filesystemutilization_warn"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "85"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/boot",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "root_filesystem_utilization_crit" {
  for_each            = var.is_enabled_filesystem_utilization_crit && var.is_enabled_root_filesystem_utilization_crit ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-root_filesystemutilization_crit"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"Critical",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "90"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "root_filesystem_utilization_warning" {
  for_each            = var.is_enabled_filesystem_utilization_warning && var.is_enabled_root_filesystem_utilization_warning ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-root_filesystemutilization_warn"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "85"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "var_log_audit_filesystem_utilization_crit" {
  for_each            = var.is_enabled_filesystem_utilization_crit && var.is_enabled_var_log_audit_filesystem_utilization_crit ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-var_log_audit_filesystemutilization_crit"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"Critical",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "90"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/var/log/audit",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "var_log_audit_filesystem_utilization_warning" {
  for_each            = var.is_enabled_filesystem_utilization_warning && var.is_enabled_var_log_audit_filesystem_utilization_warning ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-var_log_audit_filesystemutilization_warn"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "85"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/var/log/audit",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "home_filesystem_utilization_crit" {
  for_each            = var.is_enabled_filesystem_utilization_crit && var.is_enabled_home_filesystem_utilization_crit ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-home_filesystemutilization_crit"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"Critical",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "90"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/home",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "home_filesystem_utilization_warning" {
  for_each            = var.is_enabled_filesystem_utilization_warning && var.is_enabled_home_filesystem_utilization_warning ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-home_filesystemutilization_warn"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "85"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/home",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "acfs01_filesystem_utilization_crit" {
  for_each            = var.is_enabled_filesystem_utilization_crit && var.is_enabled_acfs01_filesystem_utilization_crit ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-acfs01_filesystemutilization_crit"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"Critical",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "90"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/acfs01",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "acfs01_filesystem_utilization_warning" {
  for_each            = var.is_enabled_filesystem_utilization_warning && var.is_enabled_acfs01_filesystem_utilization_warning ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-acfs01_filesystemutilization_warn"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "85"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/acfs01",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "u02_filesystem_utilization_crit" {
  for_each            = var.is_enabled_filesystem_utilization_crit && var.is_enabled_u02_filesystem_utilization_crit ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-u02_filesystemutilization_crit"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"Critical",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "90"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/u02",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "u02_filesystem_utilization_warning" {
  for_each            = var.is_enabled_filesystem_utilization_warning && var.is_enabled_u02_filesystem_utilization_warning ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-u02_filesystemutilization_warn"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "85"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/u02",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "tmp_filesystem_utilization_crit" {
  for_each            = var.is_enabled_filesystem_utilization_crit && var.is_enabled_tmp_filesystem_utilization_crit ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-tmp_filesystemutilization_crit"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"Critical",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "90"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/tmp",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "tmp_filesystem_utilization_warning" {
  for_each            = var.is_enabled_filesystem_utilization_warning && var.is_enabled_tmp_filesystem_utilization_warning ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-tmp_filesystemutilization_warn"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "85"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/tmp",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "u01_app_grid_filesystem_utilization_crit" {
  for_each            = var.is_enabled_filesystem_utilization_crit && var.is_enabled_u01_app_grid_filesystem_utilization_crit ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-u01_app_grid_filesystemutilization_crit"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P3",
                        "severity":"Critical",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "90"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/u01/app/23.0.0.0/grid",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "u01_app_grid_filesystem_utilization_warning" {
  for_each            = var.is_enabled_filesystem_utilization_warning && var.is_enabled_u01_app_grid_filesystem_utilization_warning ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-u01_app_grid_filesystemutilization_warn"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "85"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/u01/app/23.0.0.0/grid",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "var_log_filesystem_utilization_crit" {
  for_each            = var.is_enabled_filesystem_utilization_crit && var.is_enabled_var_log_filesystem_utilization_crit ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-var_log_filesystemutilization_crit"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                         {"priority":"P3",
                         "severity":"Critical",
                         "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                         "environment":"${var.environment}",
                         "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "90"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/var/log",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}

resource "aws_cloudwatch_metric_alarm" "var_log_filesystem_utilization_warning" {
  for_each            = var.is_enabled_filesystem_utilization_warning && var.is_enabled_var_log_filesystem_utilization_warning ? toset(var.db_servers) : toset([])
  alarm_name          = "${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}-var_log_filesystemutilization_warn"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                        {"priority":"P4",
                        "severity":"WARNING",
                        "entity":"${var.exainfra_name}-${var.vm_cluster_name}-${local.db_node_map[each.value].hostname}-${each.value}",
                        "environment":"${var.environment}",
                        "source":"Cloudwatch"}
                        EOT
  alarm_actions       = [var.sns_alert_arn]
  ok_actions          = [var.sns_alert_arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FilesystemUtilization"
  namespace           = "AWS/ODB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "85"
  dimensions = {
    cloudExadataInfrastructureId    = var.exainfra_id,
    cloudVmClusterId                = var.vm_cluster_id,
    deploymentType                  = "exadata",
    filesystemName                  = "/var/log",
    hostName                        = local.db_node_map[each.value].hostname,
    ociCloudExadataInfrastructureId = var.exainfra_ocid,
    ociCloudVmClusterId             = var.vm_cluster_ocid,
    resourceId                      = var.vm_cluster_ocid,
    resourceName_dbnode             = local.db_node_map[each.value].hostname,
    resourceName                    = var.vm_cluster_name
    resourceId_dbnode               = local.db_node_map[each.value].ocid,
  }
  tags = {}
}




