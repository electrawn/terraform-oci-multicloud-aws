data "aws_odb_db_servers" "db_servers" {
  cloud_exadata_infrastructure_id = var.exainfra_id
}

data "aws_odb_db_nodes" "db_nodes" {
  cloud_vm_cluster_id = var.vm_cluster_id
}

locals {
  db_server_map = {
    for db_server in data.aws_odb_db_servers.db_servers.db_servers : db_server.id => db_server
  }

  # Disable alarms when in downtime
  alarm_is_enabled = tostring(alltrue([var.alarms_enabled, !var.in_downtime]))

  base_tags = {}

  core_alarm_templates = {
    vm_cluster_cpu = {
      enabled            = alltrue([var.alarms_enabled, var.is_enabled_vm_cluster_cpu])
      alarm_suffix       = "cpu-utilization"
      notification_title = "CPU utilization (%)"
      body               = "CPU utilization threshold over 90% alarm is \"{{status}}\" for database node \"{{dimensions.resourceName}}\"."
      pending_duration   = "PT10M"
      query_metric       = "CpuUtilization"
      query_window       = "5m"
      query_stat         = "mean"
      query_operator     = ">"
      threshold          = 90
      severity           = "CRITICAL"
    }
    vm_cluster_memory = {
      enabled            = alltrue([var.alarms_enabled, var.is_enabled_vm_cluster_memory])
      alarm_suffix       = "memory-utilization"
      notification_title = "Memory utilization (%)"
      body               = "Memory utilization threshold over 90% alarm is \"{{status}}\" for database node \"{{dimensions.resourceName}}\"."
      pending_duration   = "PT10M"
      query_metric       = "MemoryUtilization"
      query_window       = "5m"
      query_stat         = "mean"
      query_operator     = ">"
      threshold          = 90
      severity           = "CRITICAL"
    }
    node_status = {
      enabled            = alltrue([var.alarms_enabled, var.is_enabled_node_status])
      alarm_suffix       = "node-status"
      notification_title = "Node status"
      body               = "Node status alarm is \"{{status}}\" when database node \"{{dimensions.resourceName}}\" is unreachable."
      pending_duration   = "PT2M"
      query_metric       = "NodeStatus"
      query_window       = "1m"
      query_stat         = "min"
      query_operator     = "<"
      threshold          = 1
      severity           = "CRITICAL"
    }
  }

  filesystem_mounts = {
    u01 = {
      path    = "/u01"
      enabled = var.is_enabled_u01_filesystem_utilization
    }
    crashfiles = {
      path    = "/crashfiles"
      enabled = var.is_enabled_crashfiles_filesystem_utilization
    }
    var = {
      path    = "/var"
      enabled = var.is_enabled_var_filesystem_utilization
    }
    boot = {
      path    = "/boot"
      enabled = var.is_enabled_boot_filesystem_utilization
    }
    root = {
      path    = "/"
      enabled = var.is_enabled_root_filesystem_utilization
    }
    var_log_audit = {
      path    = "/var/log/audit"
      enabled = var.is_enabled_var_log_audit_filesystem_utilization
    }
    home = {
      path    = "/home"
      enabled = var.is_enabled_home_filesystem_utilization
    }
    acfs01 = {
      path    = "/acfs01"
      enabled = var.is_enabled_acfs01_filesystem_utilization
    }
    u02 = {
      path    = "/u02"
      enabled = var.is_enabled_u02_filesystem_utilization
    }
    tmp = {
      path    = "/tmp"
      enabled = var.is_enabled_tmp_filesystem_utilization
    }
    u01_app_grid = {
      path    = "/u01/app/23.0.0.0/grid"
      enabled = var.is_enabled_u01_app_grid_filesystem_utilization
    }
    var_log = {
      path    = "/var/log"
      enabled = var.is_enabled_var_log_filesystem_utilization
    }
  }

  core_alarm_instances = {
    for item in flatten([
      for node in data.aws_odb_db_nodes.db_nodes.db_nodes : [
        for alarm_key, alarm in local.core_alarm_templates : {
          key                = "${node.id}-${alarm_key}"
          enabled            = alarm.enabled
          db_server_id       = node.db_server_id
          hostname           = node.hostname
          node_ocid          = node.ocid
          alarm_suffix       = alarm.alarm_suffix
          notification_title = alarm.notification_title
          body               = alarm.body
          pending_duration   = alarm.pending_duration
          severity           = alarm.severity
          query              = "${alarm.query_metric}[${alarm.query_window}]{resourceId = \"${node.ocid}\"}.${alarm.query_stat}() ${alarm.query_operator} ${alarm.threshold}"
        }
      ]
    ]) : item.key => item if item.enabled
  }

  # Consolidated filesystem alarms: one alarm per node+mount with warning base + critical override
  filesystem_alarm_instances = {
    for item in flatten([
      for node in data.aws_odb_db_nodes.db_nodes.db_nodes : [
        for fs_key, fs in local.filesystem_mounts : {
          key                = "${node.id}-${fs_key}"
          enabled            = alltrue([var.alarms_enabled, var.is_enabled_filesystem_utilization, fs.enabled])
          db_server_id       = node.db_server_id
          hostname           = node.hostname
          node_ocid          = node.ocid
          alarm_suffix       = "${fs_key}_filesystemutilization"
          notification_title = "Filesystem utilization (${fs.path})"
          body               = "Filesystem utilization threshold over 85% alarm is \"{{status}}\" for mount point \"${fs.path}\" on database node \"{{dimensions.resourceName}}\"."
          pending_duration   = "PT5M"
          severity           = "WARNING"
          query              = "FilesystemUtilization[5m]{resourceId = \"${node.ocid}\", filesystemName = \"${fs.path}\"}.min() > 85"
          override_body      = "Filesystem utilization threshold over 90% alarm is \"{{status}}\" for mount point \"${fs.path}\" on database node \"{{dimensions.resourceName}}\"."
          override_query     = "FilesystemUtilization[5m]{resourceId = \"${node.ocid}\", filesystemName = \"${fs.path}\"}.min() > 90"
        }
      ]
    ]) : item.key => item if item.enabled
  }

  alarm_instances = local.core_alarm_instances
}

resource "oci_monitoring_alarm" "db_server_alarms" {
  for_each                                      = local.alarm_instances
  body                                          = each.value.body
  compartment_id                                = var.compartment_ocid
  destinations                                  = var.destinations
  display_name                                  = "${var.exainfra_name}-${var.vm_cluster_name}-${each.value.hostname}-${each.value.db_server_id}-${each.value.alarm_suffix}"
  evaluation_slack_duration                     = "PT3M"
  freeform_tags                                 = {}
  is_enabled                                    = local.alarm_is_enabled
  is_notifications_per_metric_dimension_enabled = "false"
  message_format                                = "ONS_OPTIMIZED"
  metric_compartment_id                         = var.compartment_ocid
  metric_compartment_id_in_subtree              = "false"
  namespace                                     = "oracle_oci_database"
  notification_title                            = each.value.notification_title
  notification_version                          = "1.X"
  pending_duration                              = each.value.pending_duration
  query                                         = each.value.query
  resolution                                    = "1m"
  rule_name                                     = "base"
  severity                                      = each.value.severity
}

resource "oci_monitoring_alarm" "db_server_filesystem_alarms" {
  for_each                                      = local.filesystem_alarm_instances
  body                                          = each.value.body
  compartment_id                                = var.compartment_ocid
  destinations                                  = var.destinations
  display_name                                  = "${var.exainfra_name}-${var.vm_cluster_name}-${each.value.hostname}-${each.value.db_server_id}-${each.value.alarm_suffix}"
  evaluation_slack_duration                     = "PT3M"
  freeform_tags                                 = {}
  is_enabled                                    = local.alarm_is_enabled
  is_notifications_per_metric_dimension_enabled = "false"
  message_format                                = "ONS_OPTIMIZED"
  metric_compartment_id                         = var.compartment_ocid
  metric_compartment_id_in_subtree              = "false"
  namespace                                     = "oracle_oci_database"
  notification_title                            = each.value.notification_title
  notification_version                          = "1.X"
  pending_duration                              = each.value.pending_duration
  query                                         = each.value.query
  resolution                                    = "1m"
  rule_name                                     = "warning_rule"
  severity                                      = "WARNING"

  overrides {
    body      = each.value.override_body
    query     = each.value.override_query
    rule_name = "critical_rule"
    severity  = "CRITICAL"
  }
}
