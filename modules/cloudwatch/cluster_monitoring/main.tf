data "aws_odb_cloud_vm_cluster" "vm_cluster" {
  id = var.vm_cluster_id
}

data "aws_odb_cloud_exadata_infrastructure" "exainfra" {
  id = var.exainfra_id
}

locals {
  # Disable actions when in downtime
  alarm_actions_enabled = !var.in_downtime
}

resource "aws_cloudwatch_metric_alarm" "asm_storage_data1" {
  count               = var.is_enabled_asm_storage_data1 ? 1 : 0
  alarm_name          = "${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}-asm-data-util-data1"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                          This metric monitors VM Cluster Storage for DATA1 for ${var.environment} environment
                          {"priority":"P3",
                           "severity":"CRITICAL",
                          "noc_bypass":"true",
                          "noc_desk":"DB Services",
                          "downtime":"${var.in_downtime}",
                          "environment":"${var.environment}",
                          "entity":"${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}",
                         "source_hostname":"${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}",
                         "source_uid":"${data.aws_odb_cloud_vm_cluster.vm_cluster.ocid}",
                         "source":"Cloudwatch",
                         "support_category":"${var.support_category}",
                         "support_teams":"${var.support_teams}",
                          "docs_link":"https://wiki.example.com/docs/page-007"}
                         EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
  count               = var.is_enabled_asm_storage_reco1 ? 1 : 0
  alarm_name          = "${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}-asm-data-util-reco1"
  actions_enabled     = local.alarm_actions_enabled
  alarm_description   = <<-EOT
                         This metric monitors VM Cluster Storage for RECO1 for ${var.environment} environment
                          {"priority":"P3",
                           "severity":"CRITICAL",
                          "noc_bypass":"true",
                          "noc_desk":"DB Services",
                          "downtime":"${var.in_downtime}",
                          "environment":"${var.environment}",
                          "entity":"${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}",
                          "source_hostname":"${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}",
                          "source_uid":"${data.aws_odb_cloud_vm_cluster.vm_cluster.ocid}",
                          "source":"Cloudwatch",
                          "support_category":"${var.support_category}",
                          "support_teams":"${var.support_teams}",
                           "docs_link":"https://wiki.example.com/docs/page-007"}
                          EOT
  alarm_actions       = [var.opsgenie_alert_arn]
  ok_actions          = [var.opsgenie_alert_arn]
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
