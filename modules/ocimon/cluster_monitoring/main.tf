data "aws_odb_cloud_vm_cluster" "vm_cluster" {
  id = var.vm_cluster_id
}

data "aws_odb_cloud_exadata_infrastructure" "exainfra" {
  id = var.exainfra_id
}

locals {
  # Disable alarms when in downtime
  alarm_is_enabled = tostring(alltrue([var.alarms_enabled, !var.in_downtime]))

  base_tags = {}
}

resource "oci_monitoring_alarm" "asm_storage_data1" {
  count                                         = alltrue([var.alarms_enabled, var.is_enabled_asm_storage_data1]) ? 1 : 0
  body                                          = "ASM diskgroup DATA1 utilization threshold over 85% alarm is \"{{status}}\" for VM cluster \"{{dimensions.resourceName}}\"."
  compartment_id                                = var.compartment_ocid
  destinations                                  = var.destinations
  display_name                                  = "${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}-asm-data-util-data1"
  evaluation_slack_duration                     = "PT3M"
  freeform_tags                                 = local.base_tags
  is_enabled                                    = local.alarm_is_enabled
  is_notifications_per_metric_dimension_enabled = "false"
  message_format                                = "ONS_OPTIMIZED"
  metric_compartment_id                         = var.compartment_ocid
  metric_compartment_id_in_subtree              = "false"
  namespace                                     = "oracle_oci_database"
  notification_title                            = "ASM DATA1 utilization (%)"
  notification_version                          = "1.X"
  pending_duration                              = "PT15M"
  query                                         = "ASMDiskgroupUtilization[15m]{resourceId = \"${data.aws_odb_cloud_vm_cluster.vm_cluster.ocid}\", diskgroupName = \"ora.datac1.dg\"}.max() > 85"
  resolution                                    = "1m"
  rule_name                                     = "base"
  severity                                      = "CRITICAL"
}

resource "oci_monitoring_alarm" "asm_storage_reco1" {
  count                                         = alltrue([var.alarms_enabled, var.is_enabled_asm_storage_reco1]) ? 1 : 0
  body                                          = "ASM diskgroup RECO1 utilization threshold over 85% alarm is \"{{status}}\" for VM cluster \"{{dimensions.resourceName}}\"."
  compartment_id                                = var.compartment_ocid
  destinations                                  = var.destinations
  display_name                                  = "${data.aws_odb_cloud_exadata_infrastructure.exainfra.display_name}-${data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name}-asm-data-util-reco1"
  evaluation_slack_duration                     = "PT3M"
  freeform_tags                                 = local.base_tags
  is_enabled                                    = local.alarm_is_enabled
  is_notifications_per_metric_dimension_enabled = "false"
  message_format                                = "ONS_OPTIMIZED"
  metric_compartment_id                         = var.compartment_ocid
  metric_compartment_id_in_subtree              = "false"
  namespace                                     = "oracle_oci_database"
  notification_title                            = "ASM RECO1 utilization (%)"
  notification_version                          = "1.X"
  pending_duration                              = "PT15M"
  query                                         = "ASMDiskgroupUtilization[15m]{resourceId = \"${data.aws_odb_cloud_vm_cluster.vm_cluster.ocid}\", diskgroupName = \"ora.recoc1.dg\"}.max() > 85"
  resolution                                    = "1m"
  rule_name                                     = "base"
  severity                                      = "CRITICAL"
}
