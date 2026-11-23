data "aws_odb_cloud_vm_cluster" "vm_cluster" {
  id = var.vm_cluster_id
}

data "aws_odb_db_servers" "db_servers" {
  cloud_exadata_infrastructure_id = var.exainfra_id
}

data "aws_odb_db_nodes" "db_nodes" {
  cloud_vm_cluster_id = var.vm_cluster_id
}

data "aws_odb_cloud_exadata_infrastructure" "exainfra" {
  id = var.exainfra_id
}

locals {
  # Transform the list into a map using a for expression
  db_server_map = {
    for db_server in data.aws_odb_db_servers.db_servers.db_servers : db_server.id => db_server
  }
}

resource "aws_cloudwatch_metric_alarm" "vm_cluster_cpu" {
  #for_each =  data.aws_odb_cloud_vm_cluster.vm_cluster.db_servers
  for_each            = { for index, db_node in data.aws_odb_db_nodes.db_nodes.db_nodes : db_node.id => db_node }
  alarm_name          = "${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}-${local.db_server_map[each.value.db_server_id].display_name}-${each.value.db_server_id}-cpu-utilization"
  alarm_description   = <<-EOT
                        This metric monitors CPU for ${var.environment} environment
                        {"priority":"P3",
                        "environment":"${var.environment}",
                        "entity":"${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}-${local.db_server_map[each.value.db_server_id].display_name}-${each.value.db_server_id}",
                        "source_hostname":"${each.value.hostname}",
                        "source_uid":"${each.value.ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"${var.docs_link}"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
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
    hostName                        = each.value.hostname,
    resourceName_dbnode             = each.value.hostname,
    resourceName                    = data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name
    resourceId_dbnode               = each.value.ocid,
    ociCloudExadataInfrastructureId = data.aws_odb_cloud_exadata_infrastructure.exainfra.ocid,
    ociCloudVmClusterId             = data.aws_odb_cloud_vm_cluster.vm_cluster.ocid,
    resourceId                      = data.aws_odb_cloud_vm_cluster.vm_cluster.ocid,
  }
  tags = {
    displayName = lookup(local.db_server_map, each.value.db_server_id).display_name,
    managed_by  = "terraform",
    created_by  = var.tag_created_by,
    Team        = var.tag_team,
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "vm_cluster_memory" {
  for_each            = { for index, db_node in data.aws_odb_db_nodes.db_nodes.db_nodes : db_node.id => db_node }
  alarm_name          = "${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}-${local.db_server_map[each.value.db_server_id].display_name}-${each.value.db_server_id}-memory-utilization"
  alarm_description   = <<-EOT
                        This metric monitors database Memory  for ${var.environment} environment
                        {"priority":"P3",
                        "environment":"${var.environment}",
                        "entity":"${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}-${local.db_server_map[each.value.db_server_id].display_name}-${each.value.db_server_id}",
                        "source_hostname":"${each.value.hostname}",
                        "source_uid":"${each.value.ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"${var.docs_link}"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
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
    hostName                        = each.value.hostname,
    resourceName_dbnode             = each.value.hostname,
    resourceName                    = data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name
    resourceId_dbnode               = each.value.ocid,
    ociCloudExadataInfrastructureId = data.aws_odb_cloud_exadata_infrastructure.exainfra.ocid,
    ociCloudVmClusterId             = data.aws_odb_cloud_vm_cluster.vm_cluster.ocid,
    resourceId                      = data.aws_odb_cloud_vm_cluster.vm_cluster.ocid,
  }
  tags = {
    displayName = lookup(local.db_server_map, each.value.db_server_id).display_name,
    managed_by  = "terraform",
    created_by  = var.tag_created_by,
    Team        = var.tag_team,
    Environment = var.environment
  }
}


resource "aws_cloudwatch_metric_alarm" "node_status" {
  for_each            = { for index, db_node in data.aws_odb_db_nodes.db_nodes.db_nodes : db_node.id => db_node }
  alarm_name          = "${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}-${local.db_server_map[each.value.db_server_id].display_name}-${each.value.db_server_id}-node-status"
  alarm_description   = <<-EOT
                        This metric monitors database Node Status (Reachable as defined by AWS) for ${var.environment} environment
                        {"priority":"P3",
                        "environment":"${var.environment}",
                        "entity":"${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}-${local.db_server_map[each.value.db_server_id].display_name}-${each.value.db_server_id}",
                        "source_hostname":"${each.value.hostname}",
                        "source_uid":"${each.value.ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"${var.docs_link}"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
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
    hostName                        = each.value.hostname,
    resourceName_dbnode             = each.value.hostname,
    resourceName                    = data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name
    resourceId_dbnode               = each.value.ocid,
    ociCloudExadataInfrastructureId = data.aws_odb_cloud_exadata_infrastructure.exainfra.ocid,
    ociCloudVmClusterId             = data.aws_odb_cloud_vm_cluster.vm_cluster.ocid,
    resourceId                      = data.aws_odb_cloud_vm_cluster.vm_cluster.ocid,
  }
  tags = {
    displayName = lookup(local.db_server_map, each.value.db_server_id).display_name,
    managed_by  = "terraform",
    created_by  = var.tag_created_by,
    Team        = var.tag_team,
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "asm_storage_data1" {
  alarm_name          = "${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}-asm-data-util-data1"
  alarm_description   = <<-EOT
                        This metric monitors VM Cluster Storage for DATA1 for ${var.environment} environment
                        {"priority":"P3",
                        "environment":"${var.environment}",
                        "entity":"${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}",
                        "source_uid":"${data.aws_odb_cloud_vm_cluster.vm_cluster.ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"${var.docs_link}"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "ASMDiskgroupUtilization"
  namespace           = "AWS/ODB"
  period              = "900"
  statistic           = "Maximum"
  threshold           = "85"
  dimensions = {
    cloudVmClusterId                = var.vm_cluster_id,
    cloudExadataInfrastructureId    = var.exainfra_id,
    deploymentType                  = "exadata",
    ociCloudExadataInfrastructureId = data.aws_odb_cloud_exadata_infrastructure.exainfra.ocid,
    ociCloudVmClusterId             = data.aws_odb_cloud_vm_cluster.vm_cluster.ocid,
    resourceId                      = data.aws_odb_cloud_vm_cluster.vm_cluster.ocid,
    resourceName                    = data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name
    diskgroupName                   = "ora.datac1.dg"
  }
  tags = {
    managed_by  = "terraform",
    created_by  = var.tag_created_by,
    Team        = var.tag_team,
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "asm_storage_reco1" {
  alarm_name          = "${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}-asm-data-util-reco1"
  alarm_description   = <<-EOT
                        This metric monitors VM Cluster Storage for RECO1 for ${var.environment} environment
                        {"priority":"P3",
                         "severity":"Critical",
                        "environment":"${var.environment}",
                        "entity":"${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}",
                        "source_uid":"${data.aws_odb_cloud_vm_cluster.vm_cluster.ocid}",
                        "source":"Cloudwatch",
                        "support_category":"${var.support_category}",
                        "support_teams":"${var.support_teams}",
                        "docs_link":"${var.docs_link}"}
                        EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "ASMDiskgroupUtilization"
  namespace           = "AWS/ODB"
  period              = "900"
  statistic           = "Maximum"
  threshold           = "85"
  dimensions = {
    cloudVmClusterId                = var.vm_cluster_id,
    cloudExadataInfrastructureId    = var.exainfra_id,
    deploymentType                  = "exadata",
    ociCloudExadataInfrastructureId = data.aws_odb_cloud_exadata_infrastructure.exainfra.ocid,
    ociCloudVmClusterId             = data.aws_odb_cloud_vm_cluster.vm_cluster.ocid,
    resourceId                      = data.aws_odb_cloud_vm_cluster.vm_cluster.ocid,
    resourceName                    = data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name
    diskgroupName                   = "ora.recoc1.dg"
  }
  tags = {
    managed_by  = "terraform",
    created_by  = var.tag_created_by,
    Team        = var.tag_team,
    Environment = var.environment
  }
}
