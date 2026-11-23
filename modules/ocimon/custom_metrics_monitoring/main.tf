# ---------------------------------------------------------------------------
# Custom-namespace OCI Monitoring alarms (namespace: example_oracledb_aws),
# emitted by the oci-functions project.
#
#   sshstatus                       – per DB node       (0 = OK, 1 = FAILED)
#   oracle_service_status           – per database      (0 = OK, 1 = FAILED)
#   libcache_mutex_waiting_sessions – per RAC instance  (sessions waiting >= 15 min on library cache: mutex X)
#
# sshstatus / oracle_service_status fire when the value indicates FAILED (> 0).
# libcache_mutex fires at P4 when a 15-minute datapoint is at or above the
# threshold, per RAC instance (inst_id dimension), and clears on the next
# datapoint below it.
#
# Metric names and dimensions follow the oci-functions source:
#   sshstatus dims:                       node_id, node_hostname, ip_address, status, vm_cluster
#   oracle_service_status dims:           database_name, scan_address, port, status
#   libcache_mutex_waiting_sessions dims: cluster_name, database_name, inst_id, query_node, role
# ---------------------------------------------------------------------------

data "aws_odb_db_nodes" "db_nodes" {
  cloud_vm_cluster_id = var.vm_cluster_id
}

locals {
  alarm_is_enabled = tostring(alltrue([var.ocimon_alarms_enabled, !var.in_downtime]))

  base_tags = merge(
    var.tags != null ? var.tags : {},
    {
      managed_by  = "terraform"
      created_by  = var.tag_created_by
      Team        = var.tag_team
      Environment = var.environment
    }
  )

  # One sshstatus alarm per DB node, keyed by node id. Query filters on the
  # node hostname dimension; fires when any FAILED (value 1) sample appears.
  ssh_alarm_nodes = alltrue([var.ocimon_alarms_enabled, var.is_enabled_sshstatus]) ? {
    for node in data.aws_odb_db_nodes.db_nodes.db_nodes : node.id => node
  } : {}

  # One oracle_service_status alarm per database service name.
  oracle_service_dbs = alltrue([var.ocimon_alarms_enabled, var.is_enabled_oracle_service_status]) ? toset(var.oracle_service_databases) : toset([])

  # Reporting / CPH service checks (same oracle_service_status metric,
  # distinguished by the service_type dimension the oci-function emits).
  reporting_service_dbs = alltrue([var.ocimon_alarms_enabled, var.is_enabled_reporting_service_status]) ? var.reporting_service_databases : {}
  cph_service_dbs       = alltrue([var.ocimon_alarms_enabled, var.is_enabled_cph_service_status]) ? var.cph_services : {}

  # libcache_mutex_waiting_sessions is emitted per (database, RAC instance). We create
  # ONE P4 alarm per PDB (keyed by its database_name dimension) and let OCI
  # split notifications per inst_id, so each RAC instance of that PDB that
  # breaches is reported individually. The set of PDBs comes from
  # var.libcache_databases (falls back to var.oracle_service_databases, which is
  # typically the same service-name list).
  libcache_enabled = alltrue([var.ocimon_alarms_enabled, var.is_enabled_libcache_waiting_sessions])
  libcache_dbs = local.libcache_enabled ? toset(
    length(var.libcache_databases) > 0 ? var.libcache_databases : var.oracle_service_databases
  ) : toset([])
}

# ---------------------------------------------------------------------------
# sshstatus – per DB node
# ---------------------------------------------------------------------------
resource "oci_monitoring_alarm" "sshstatus" {
  for_each = local.ssh_alarm_nodes

  body = <<-EOT
    SSH reachability check FAILED (sshstatus=1) alarm is "{{status}}" for DB node "${each.value.hostname}" on VM cluster "${var.vm_cluster_name}".
    ${jsonencode({
  priority         = "P3"
  severity         = "CRITICAL"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${each.value.hostname}"
  source_hostname  = each.value.hostname
  source_uid       = each.value.ocid
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.docs_link
})}
  EOT

compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${each.value.hostname}-sshstatus"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = merge(local.base_tags, { node_hostname = each.value.hostname })
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "false"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = var.metric_namespace
notification_title                            = "SSH status (node unreachable)"
notification_version                          = "1.X"
pending_duration                              = "PT5M"
query                                         = "sshstatus[5m]{node_hostname = \"${each.value.hostname}\"}.max() > 0"
resolution                                    = "1m"
rule_name                                     = "base"
severity                                      = "CRITICAL"
}

# ---------------------------------------------------------------------------
# oracle_service_status – per database
# ---------------------------------------------------------------------------
resource "oci_monitoring_alarm" "oracle_service_status" {
  for_each = local.oracle_service_dbs

  body = <<-EOT
    Oracle service connectivity check FAILED (oracle_service_status=1) alarm is "{{status}}" for database "${each.value}".
    ${jsonencode({
  priority         = "P4"
  severity         = "WARNING"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${each.value}"
  source_hostname  = var.vm_cluster_name
  source_uid       = each.value
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.docs_link
})}
  EOT

compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${each.value}-oracle_service_status"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = merge(local.base_tags, { database_name = each.value })
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "false"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = var.metric_namespace
notification_title                            = "Oracle service status (login failed)"
notification_version                          = "1.X"
pending_duration                              = "PT5M"
query                                         = "oracle_service_status[5m]{database_name = \"${each.value}\"}.max() > 0"
resolution                                    = "1m"
rule_name                                     = "base"
severity                                      = "WARNING"
}

# ---------------------------------------------------------------------------
# reporting-service-status – one P4 alarm per REPORTING PDB
#
# The oracle-service-check function logs in to the read-only service each
# reporting PDB provides and emits oracle_service_status (0 OK / 1 FAILED)
# with service_type=reporting and database_name = the lowercase PDB name.
# Named <cluster>-<pdb>-reporting-service-status, e.g.
# exa3vmc1-pdb051-reporting-service-status.
# ---------------------------------------------------------------------------
resource "oci_monitoring_alarm" "reporting_service_status" {
  for_each = local.reporting_service_dbs

  body = <<-EOT
    Reporting service check FAILED (oracle_service_status=1) alarm is "{{status}}" for reporting PDB "${each.key}" (service "${each.value}") on VM cluster "${var.vm_cluster_name}".
    ${jsonencode({
  priority         = "P4"
  severity         = "WARNING"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${each.key}"
  source_hostname  = var.vm_cluster_name
  source_uid       = "${var.vm_cluster_name}-${each.key}"
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.docs_link
})}
  EOT

compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${each.key}-reporting-service-status"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = merge(local.base_tags, { database_name = each.key, service_name = each.value, service_type = "reporting" })
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "false"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = var.metric_namespace
notification_title                            = "Reporting service status (login failed)"
notification_version                          = "1.X"
pending_duration                              = "PT5M"
query                                         = "oracle_service_status[5m]{cluster_name = \"${var.vm_cluster_name}\", database_name = \"${each.key}\", service_type = \"reporting\"}.max() > 0"
resolution                                    = "1m"
rule_name                                     = "base"
severity                                      = "WARNING"
}

# ---------------------------------------------------------------------------
# CPH service-status – one P4 alarm per CPH service
#
# CPH services run on Data Guard standbys (e.g. ee4bwcph_pdb014 on
# ee4bwcpg_exa3vmc1). The oracle-service-check function logs in to the
# service and emits oracle_service_status with service_type=cph and
# database_name = the service name. Named <cluster>-<service>-service-status,
# e.g. exa3vmc1-ee4bwcph_pdb014-service-status.
# ---------------------------------------------------------------------------
resource "oci_monitoring_alarm" "cph_service_status" {
  for_each = local.cph_service_dbs

  body = <<-EOT
    CPH service check FAILED (oracle_service_status=1) alarm is "{{status}}" for service "${each.key}" on standby "${each.value}" (VM cluster "${var.vm_cluster_name}").
    ${jsonencode({
  priority         = "P4"
  severity         = "WARNING"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${each.key}"
  source_hostname  = var.vm_cluster_name
  source_uid       = "${var.vm_cluster_name}-${each.key}"
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.docs_link
})}
  EOT

compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${each.key}-service-status"
evaluation_slack_duration                     = "PT3M"
freeform_tags                                 = merge(local.base_tags, { service_name = each.key, db_unique_name = each.value, service_type = "cph" })
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "false"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = var.metric_namespace
notification_title                            = "CPH service status (login failed)"
notification_version                          = "1.X"
pending_duration                              = "PT5M"
query                                         = "oracle_service_status[5m]{cluster_name = \"${var.vm_cluster_name}\", service_name = \"${each.key}\", service_type = \"cph\"}.max() > 0"
resolution                                    = "1m"
rule_name                                     = "base"
severity                                      = "WARNING"
}

# ---------------------------------------------------------------------------
# libcache_mutex – one P4 (WARNING) alarm per PDB
#
# The libcache-mutex function runs every 15 minutes, iterates every PDB on the
# cluster, and emits libcache_mutex_waiting_sessions per (database_name,
# inst_id): the realtime count of sessions WAITING on 'library cache: mutex X'
# for >= 900 seconds (GV$SESSION). Instances with no such sessions are emitted
# as 0.
#
# The alarm fires only after the breach is sustained for FOUR consecutive
# 15-minute datapoints (one hour in the over condition): the condition must
# hold for pending_duration = PT1H, and a single datapoint below the threshold
# resets it. It clears once a run's datapoint drops below the threshold.
# We create ONE alarm per PDB, keyed by
# its database_name dimension, with is_notifications_per_metric_dimension_enabled
# so each breaching RAC instance of that PDB is reported individually. The PDB
# set comes from var.libcache_databases (service names), falling back to
# var.oracle_service_databases.
# ---------------------------------------------------------------------------
resource "oci_monitoring_alarm" "libcache_mutex" {
  for_each = local.libcache_dbs

  body = <<-EOT
    libcache_mutex: sessions waiting >= 15 min on 'library cache: mutex X' at or above threshold (>= ${var.libcache_warning_threshold}) alarm is "{{status}}" for RAC instance "{{dimensions.inst_id}}" of database "${each.value}" on VM cluster "${var.vm_cluster_name}".
    ${jsonencode({
  priority         = "P4"
  severity         = "WARNING"
  noc_bypass       = "true"
  noc_desk         = "DB Services"
  downtime         = tostring(var.in_downtime)
  environment      = var.environment
  entity           = "${var.vm_cluster_name}-${each.value}-{{dimensions.inst_id}}"
  source_hostname  = var.vm_cluster_name
  source           = "OCImon"
  support_category = var.support_category
  support_teams    = var.support_teams
  docs_link        = var.libcache_mutex_docs_link
})}
  EOT

compartment_id                                = var.compartment_ocid
destinations                                  = var.destinations
display_name                                  = "${var.vm_cluster_name}-${each.value}-mutex_waiting_sessions"
evaluation_slack_duration                     = "PT5M"
freeform_tags                                 = merge(local.base_tags, { metric = "libcache_mutex_waiting_sessions", level = "warning", database_name = each.value })
is_enabled                                    = local.alarm_is_enabled
is_notifications_per_metric_dimension_enabled = "true"
message_format                                = "ONS_OPTIMIZED"
metric_compartment_id                         = var.compartment_ocid
metric_compartment_id_in_subtree              = "false"
namespace                                     = var.metric_namespace
notification_title                            = "libcache_mutex: library cache mutex X waits (P4)"
notification_version                          = "1.X"
# Fire after FOUR consecutive breaching 15-minute datapoints: the condition
# must hold continuously for 1 hour (datapoints at T, T+15, T+30, T+45 all at
# or above the threshold -> FIRING at ~T+60).
pending_duration = "PT1H"
# [20m] window, not [15m]: OCI re-evaluates every minute and any minute where
# the condition is not met resets pending_duration. Datapoints are stamped at
# function completion, so the gap between runs drifts a little past 15 min
# (cold start / runtime jitter); a [15m] window would then briefly contain NO
# datapoint, reset the 1h pending timer, and the alarm would never fire. A
# [20m] window always holds the latest datapoint, while a single datapoint
# below the threshold still breaks the run within ~5 minutes.
# Scoped to this cluster because the same PDB service name can exist on several
# clusters (e.g. the PDB008 template on every prd cluster).
query      = "libcache_mutex_waiting_sessions[20m]{cluster_name = \"${var.vm_cluster_name}\", database_name = \"${each.value}\"}.max() >= ${var.libcache_warning_threshold}"
resolution = "1m"
rule_name  = "base"
severity   = "WARNING"
}

# Renamed from libcache_waiting_sessions_warning; update the existing alarms
# in place (OCID and history kept) instead of destroying and recreating them.
moved {
  from = oci_monitoring_alarm.libcache_waiting_sessions_warning
  to   = oci_monitoring_alarm.libcache_mutex
}
