# =========================================================================
# 4_monitoring — Dedicated Monitoring Stage (PRD)
# =========================================================================
# This stage centralizes all monitoring resources for prd:
#   - Compute infrastructure alarms (CloudWatch cluster per exadata rack)
#   - Database-specific alarms (CloudWatch and OCI Monitoring for CDBs and PDBs)
#   - Log analytics entities and source associations
#
# Remote State Dependencies:
#   - 0_bootstrap: Provides monitor_compartment_ocid
#   - 2_compute: Provides exainfra_id, vm_cluster_id, and related metadata
#   - 3_databases: Provides CDB and PDB resource IDs and metadata
# =========================================================================

# ========================================
# COMPUTE INFRASTRUCTURE MONITORING
# ========================================

# CloudWatch Cluster-level monitoring — exa1
module "cloudwatch_cluster_monitoring_exa1" {
  count = local.enable_cluster_monitoring ? 1 : 0

  source             = "../../../modules/cloudwatch/cluster_monitoring"
  exainfra_id        = local.exa1.exainfra_id
  vm_cluster_id      = local.exa1.vm_cluster_id
  environment        = var.environment
  opsgenie_alert_arn = var.opsgenie_alert_arn
  in_downtime        = var.in_downtime
  support_category   = var.support_category
  support_teams      = var.support_teams

  depends_on = [data.terraform_remote_state.compute]
}

# CloudWatch Cluster-level monitoring — exa2
module "cloudwatch_cluster_monitoring_exa2" {
  count = local.exa2.vm_cluster_id != "" ? 1 : 0

  source             = "../../../modules/cloudwatch/cluster_monitoring"
  exainfra_id        = local.exa2.exainfra_id
  vm_cluster_id      = local.exa2.vm_cluster_id
  environment        = var.environment
  opsgenie_alert_arn = var.opsgenie_alert_arn
  in_downtime        = var.in_downtime
  support_category   = var.support_category
  support_teams      = var.support_teams

  depends_on = [data.terraform_remote_state.compute]
}

# CloudWatch Cluster-level monitoring — exa3
module "cloudwatch_cluster_monitoring_exa3" {
  count = local.exa3.vm_cluster_id != "" ? 1 : 0

  source             = "../../../modules/cloudwatch/cluster_monitoring"
  exainfra_id        = local.exa3.exainfra_id
  vm_cluster_id      = local.exa3.vm_cluster_id
  environment        = var.environment
  opsgenie_alert_arn = var.opsgenie_alert_arn
  in_downtime        = var.in_downtime
  support_category   = var.support_category
  support_teams      = var.support_teams

  depends_on = [data.terraform_remote_state.compute]
}

# ========================================
# COMPUTE INFRASTRUCTURE - DB Server Monitoring (per-node filesystem alarms)
# ========================================

# DB Server monitoring — exa1
module "cloudwatch_db_server_monitoring_exa1" {
  count = local.exa1.db_servers != null && local.exa1.db_nodes != null ? 1 : 0

  source                 = "../../../modules/cloudwatch/db_server_monitoring"
  exainfra_id            = local.exa1.exainfra_id
  exainfra_name          = local.exa1.exainfra_name
  exainfra_ocid          = local.exa1.exainfra_ocid
  db_servers             = try([for s in local.exa1.db_servers.db_servers : s.id], [])
  aws_exainfra_dbservers = local.exa1.db_servers
  vm_cluster_name        = local.exa1.vm_cluster_name
  vm_cluster_id          = local.exa1.vm_cluster_id
  vm_cluster_ocid        = local.exa1.vm_cluster_ocid
  aws_vmcluster_dbnodes  = local.exa1.db_nodes
  environment            = var.environment
  opsgenie_alert_arn     = var.opsgenie_alert_arn
  in_downtime            = var.in_downtime
  support_category       = var.support_category
  support_teams          = var.support_teams

  depends_on = [data.terraform_remote_state.compute]
}

# DB Server monitoring — exa2
module "cloudwatch_db_server_monitoring_exa2" {
  count = local.exa2.db_servers != null && local.exa2.db_nodes != null ? 1 : 0

  source                 = "../../../modules/cloudwatch/db_server_monitoring"
  exainfra_id            = local.exa2.exainfra_id
  exainfra_name          = local.exa2.exainfra_name
  exainfra_ocid          = local.exa2.exainfra_ocid
  db_servers             = try([for s in local.exa2.db_servers.db_servers : s.id], [])
  aws_exainfra_dbservers = local.exa2.db_servers
  vm_cluster_name        = local.exa2.vm_cluster_name
  vm_cluster_id          = local.exa2.vm_cluster_id
  vm_cluster_ocid        = local.exa2.vm_cluster_ocid
  aws_vmcluster_dbnodes  = local.exa2.db_nodes
  environment            = var.environment
  opsgenie_alert_arn     = var.opsgenie_alert_arn
  in_downtime            = var.in_downtime
  support_category       = var.support_category
  support_teams          = var.support_teams

  depends_on = [data.terraform_remote_state.compute]
}

# DB Server monitoring — exa3
module "cloudwatch_db_server_monitoring_exa3" {
  count = local.exa3.db_servers != null && local.exa3.db_nodes != null ? 1 : 0

  source                 = "../../../modules/cloudwatch/db_server_monitoring"
  exainfra_id            = local.exa3.exainfra_id
  exainfra_name          = local.exa3.exainfra_name
  exainfra_ocid          = local.exa3.exainfra_ocid
  db_servers             = try([for s in local.exa3.db_servers.db_servers : s.id], [])
  aws_exainfra_dbservers = local.exa3.db_servers
  vm_cluster_name        = local.exa3.vm_cluster_name
  vm_cluster_id          = local.exa3.vm_cluster_id
  vm_cluster_ocid        = local.exa3.vm_cluster_ocid
  aws_vmcluster_dbnodes  = local.exa3.db_nodes
  environment            = var.environment
  opsgenie_alert_arn     = var.opsgenie_alert_arn
  in_downtime            = var.in_downtime
  support_category       = var.support_category
  support_teams          = var.support_teams

  depends_on = [data.terraform_remote_state.compute]
}

# ========================================
# DATABASE MONITORING - CloudWatch CDB (exa1)
# ========================================
module "cloudwatch_cdb_monitoring_exa1" {
  for_each = local.exa1_cdbs

  source             = "../../../modules/cloudwatch/cdb_monitoring"
  exainfra_id        = local.exa1.exainfra_id
  exainfra_ocid      = local.exa1.exainfra_ocid
  vm_cluster_id      = local.exa1.vm_cluster_id
  vm_cluster_name    = local.exa1.vm_cluster_name
  vm_cluster_ocid    = local.exa1.vm_cluster_ocid
  database_name      = each.value.name
  database_ocid      = each.value.ocid
  environment        = var.environment
  opsgenie_alert_arn = var.opsgenie_alert_arn
  alarms_enabled     = each.value.resolved.alarms_enabled
  in_downtime        = var.in_downtime
  support_category   = var.support_category
  support_teams      = var.support_teams
  tag_team           = var.tag_team
  tag_created_by     = var.tag_created_by
  tags               = merge(var.tags, { "Environment" : var.environment })

  depends_on = [data.terraform_remote_state.databases]
}

# DATABASE MONITORING - CloudWatch CDB (exa2)
module "cloudwatch_cdb_monitoring_exa2" {
  for_each = local.exa2_cdbs

  source             = "../../../modules/cloudwatch/cdb_monitoring"
  exainfra_id        = local.exa2.exainfra_id
  exainfra_ocid      = local.exa2.exainfra_ocid
  vm_cluster_id      = local.exa2.vm_cluster_id
  vm_cluster_name    = local.exa2.vm_cluster_name
  vm_cluster_ocid    = local.exa2.vm_cluster_ocid
  database_name      = each.value.name
  database_ocid      = each.value.ocid
  environment        = var.environment
  opsgenie_alert_arn = var.opsgenie_alert_arn
  alarms_enabled     = each.value.resolved.alarms_enabled
  in_downtime        = var.in_downtime
  support_category   = var.support_category
  support_teams      = var.support_teams
  tag_team           = var.tag_team
  tag_created_by     = var.tag_created_by
  tags               = merge(var.tags, { "Environment" : var.environment })

  depends_on = [data.terraform_remote_state.databases]
}

# DATABASE MONITORING - CloudWatch CDB (exa3)
module "cloudwatch_cdb_monitoring_exa3" {
  for_each = local.exa3_cdbs

  source             = "../../../modules/cloudwatch/cdb_monitoring"
  exainfra_id        = local.exa3.exainfra_id
  exainfra_ocid      = local.exa3.exainfra_ocid
  vm_cluster_id      = local.exa3.vm_cluster_id
  vm_cluster_name    = local.exa3.vm_cluster_name
  vm_cluster_ocid    = local.exa3.vm_cluster_ocid
  database_name      = each.value.name
  database_ocid      = each.value.ocid
  environment        = var.environment
  opsgenie_alert_arn = var.opsgenie_alert_arn
  alarms_enabled     = each.value.resolved.alarms_enabled
  in_downtime        = var.in_downtime
  support_category   = var.support_category
  support_teams      = var.support_teams
  tag_team           = var.tag_team
  tag_created_by     = var.tag_created_by
  tags               = merge(var.tags, { "Environment" : var.environment })

  depends_on = [data.terraform_remote_state.databases]
}

# ========================================
# DATABASE MONITORING - OCI Monitoring CDB (exa1)
# ========================================
module "ocimon_cdb_monitoring_exa1" {
  for_each = local.exa1_cdbs

  source                = "../../../modules/ocimon/cdb_monitoring"
  exainfra_id           = local.exa1.exainfra_id
  exainfra_ocid         = local.exa1.exainfra_ocid
  vm_cluster_id         = local.exa1.vm_cluster_id
  vm_cluster_name       = local.exa1.vm_cluster_name
  vm_cluster_ocid       = local.exa1.vm_cluster_ocid
  database_name         = each.value.name
  database_ocid         = each.value.ocid
  compartment_ocid      = each.value.compartment
  environment           = var.environment
  opsgenie_alert_arn    = var.opsgenie_alert_arn
  ocimon_alarms_enabled = each.value.resolved.ocimon_alarms_enabled
  destinations          = [var.notification_topic_ocid]

  is_enabled_ocimon_cdb_tablespace_utilization          = false
  is_enabled_ocimon_cdb_storage_utilization             = false
  is_enabled_ocimon_cdb_processes_utilization           = false
  is_enabled_ocimon_cdb_user_password_expiration        = false
  is_enabled_ocimon_cdb_cpu_utilization                 = false
  is_enabled_ocimon_cdb_flash_recovery_area_utilization = false
  is_enabled_ocimon_cdb_backup_status_failed            = false
  is_enabled_ocimon_cdb_apply_lag                       = each.value.resolved.is_enabled_ocimon_apply_lag
  is_enabled_ocimon_cdb_transport_lag                   = each.value.resolved.is_enabled_ocimon_transport_lag

  depends_on = [data.terraform_remote_state.databases]
}

# OCI Monitoring CDB (exa2)
module "ocimon_cdb_monitoring_exa2" {
  for_each = local.exa2_cdbs

  source                = "../../../modules/ocimon/cdb_monitoring"
  exainfra_id           = local.exa2.exainfra_id
  exainfra_ocid         = local.exa2.exainfra_ocid
  vm_cluster_id         = local.exa2.vm_cluster_id
  vm_cluster_name       = local.exa2.vm_cluster_name
  vm_cluster_ocid       = local.exa2.vm_cluster_ocid
  database_name         = each.value.name
  database_ocid         = each.value.ocid
  compartment_ocid      = each.value.compartment
  environment           = var.environment
  opsgenie_alert_arn    = var.opsgenie_alert_arn
  ocimon_alarms_enabled = each.value.resolved.ocimon_alarms_enabled
  destinations          = [var.notification_topic_ocid]

  is_enabled_ocimon_cdb_tablespace_utilization          = false
  is_enabled_ocimon_cdb_storage_utilization             = false
  is_enabled_ocimon_cdb_processes_utilization           = false
  is_enabled_ocimon_cdb_user_password_expiration        = false
  is_enabled_ocimon_cdb_cpu_utilization                 = false
  is_enabled_ocimon_cdb_flash_recovery_area_utilization = false
  is_enabled_ocimon_cdb_backup_status_failed            = false
  is_enabled_ocimon_cdb_apply_lag                       = each.value.resolved.is_enabled_ocimon_apply_lag
  is_enabled_ocimon_cdb_transport_lag                   = each.value.resolved.is_enabled_ocimon_transport_lag

  depends_on = [data.terraform_remote_state.databases]
}

# OCI Monitoring CDB (exa3)
module "ocimon_cdb_monitoring_exa3" {
  for_each = local.exa3_cdbs

  source                = "../../../modules/ocimon/cdb_monitoring"
  exainfra_id           = local.exa3.exainfra_id
  exainfra_ocid         = local.exa3.exainfra_ocid
  vm_cluster_id         = local.exa3.vm_cluster_id
  vm_cluster_name       = local.exa3.vm_cluster_name
  vm_cluster_ocid       = local.exa3.vm_cluster_ocid
  database_name         = each.value.name
  database_ocid         = each.value.ocid
  compartment_ocid      = each.value.compartment
  environment           = var.environment
  opsgenie_alert_arn    = var.opsgenie_alert_arn
  ocimon_alarms_enabled = each.value.resolved.ocimon_alarms_enabled
  destinations          = [var.notification_topic_ocid]

  is_enabled_ocimon_cdb_tablespace_utilization          = false
  is_enabled_ocimon_cdb_storage_utilization             = false
  is_enabled_ocimon_cdb_processes_utilization           = false
  is_enabled_ocimon_cdb_user_password_expiration        = false
  is_enabled_ocimon_cdb_cpu_utilization                 = false
  is_enabled_ocimon_cdb_flash_recovery_area_utilization = false
  is_enabled_ocimon_cdb_backup_status_failed            = false
  is_enabled_ocimon_cdb_apply_lag                       = each.value.resolved.is_enabled_ocimon_apply_lag
  is_enabled_ocimon_cdb_transport_lag                   = each.value.resolved.is_enabled_ocimon_transport_lag

  depends_on = [data.terraform_remote_state.databases]
}

# ========================================
# DATABASE MONITORING - CloudWatch PDB (exa1)
# ========================================
module "cloudwatch_pdb_monitoring_exa1" {
  for_each = local.exa1_pdbs

  source             = "../../../modules/cloudwatch/pdb_monitoring"
  exainfra_id        = local.exa1.exainfra_id
  exainfra_ocid      = local.exa1.exainfra_ocid
  vm_cluster_id      = local.exa1.vm_cluster_id
  vm_cluster_name    = local.exa1.vm_cluster_name
  vm_cluster_ocid    = local.exa1.vm_cluster_ocid
  database_name      = each.value.name
  database_ocid      = each.value.ocid
  environment        = var.environment
  opsgenie_alert_arn = var.opsgenie_alert_arn
  alarms_enabled     = each.value.resolved.alarms_enabled
  in_downtime        = var.in_downtime
  support_category   = var.support_category
  support_teams      = var.support_teams
  tag_team           = var.tag_team
  tag_created_by     = var.tag_created_by
  tags               = merge(var.tags, { "Environment" : var.environment })

  depends_on = [data.terraform_remote_state.databases]
}

# CloudWatch PDB (exa2)
module "cloudwatch_pdb_monitoring_exa2" {
  for_each = local.exa2_pdbs

  source             = "../../../modules/cloudwatch/pdb_monitoring"
  exainfra_id        = local.exa2.exainfra_id
  exainfra_ocid      = local.exa2.exainfra_ocid
  vm_cluster_id      = local.exa2.vm_cluster_id
  vm_cluster_name    = local.exa2.vm_cluster_name
  vm_cluster_ocid    = local.exa2.vm_cluster_ocid
  database_name      = each.value.name
  database_ocid      = each.value.ocid
  environment        = var.environment
  opsgenie_alert_arn = var.opsgenie_alert_arn
  alarms_enabled     = each.value.resolved.alarms_enabled
  in_downtime        = var.in_downtime
  support_category   = var.support_category
  support_teams      = var.support_teams
  tag_team           = var.tag_team
  tag_created_by     = var.tag_created_by
  tags               = merge(var.tags, { "Environment" : var.environment })

  depends_on = [data.terraform_remote_state.databases]
}

# CloudWatch PDB (exa3)
module "cloudwatch_pdb_monitoring_exa3" {
  for_each = local.exa3_pdbs

  source             = "../../../modules/cloudwatch/pdb_monitoring"
  exainfra_id        = local.exa3.exainfra_id
  exainfra_ocid      = local.exa3.exainfra_ocid
  vm_cluster_id      = local.exa3.vm_cluster_id
  vm_cluster_name    = local.exa3.vm_cluster_name
  vm_cluster_ocid    = local.exa3.vm_cluster_ocid
  database_name      = each.value.name
  database_ocid      = each.value.ocid
  environment        = var.environment
  opsgenie_alert_arn = var.opsgenie_alert_arn
  alarms_enabled     = each.value.resolved.alarms_enabled
  in_downtime        = var.in_downtime
  support_category   = var.support_category
  support_teams      = var.support_teams
  tag_team           = var.tag_team
  tag_created_by     = var.tag_created_by
  tags               = merge(var.tags, { "Environment" : var.environment })

  depends_on = [data.terraform_remote_state.databases]
}

# ========================================
# DATABASE MONITORING - OCI Monitoring PDB (exa1)
# ========================================
module "ocimon_pdb_monitoring_exa1" {
  for_each = local.exa1_pdbs

  source                = "../../../modules/ocimon/pdb_monitoring"
  exainfra_id           = local.exa1.exainfra_id
  exainfra_ocid         = local.exa1.exainfra_ocid
  vm_cluster_id         = local.exa1.vm_cluster_id
  vm_cluster_name       = local.exa1.vm_cluster_name
  vm_cluster_ocid       = local.exa1.vm_cluster_ocid
  database_name         = each.value.name
  database_ocid         = each.value.ocid
  compartment_ocid      = each.value.compartment
  environment           = var.environment
  opsgenie_alert_arn    = var.opsgenie_alert_arn
  ocimon_alarms_enabled = each.value.resolved.ocimon_alarms_enabled
  destinations          = [var.notification_topic_ocid]

  is_enabled_ocimon_pdb_tablespace_utilization   = false
  is_enabled_ocimon_pdb_storage_utilization      = false
  is_enabled_ocimon_pdb_processes_utilization    = false
  is_enabled_ocimon_pdb_user_password_expiration = false
  is_enabled_ocimon_pdb_cpu_utilization          = false
  is_enabled_ocimon_pdb_blocking_sessions_count  = false

  depends_on = [data.terraform_remote_state.databases]
}

# OCI Monitoring PDB (exa2)
module "ocimon_pdb_monitoring_exa2" {
  for_each = local.exa2_pdbs

  source                = "../../../modules/ocimon/pdb_monitoring"
  exainfra_id           = local.exa2.exainfra_id
  exainfra_ocid         = local.exa2.exainfra_ocid
  vm_cluster_id         = local.exa2.vm_cluster_id
  vm_cluster_name       = local.exa2.vm_cluster_name
  vm_cluster_ocid       = local.exa2.vm_cluster_ocid
  database_name         = each.value.name
  database_ocid         = each.value.ocid
  compartment_ocid      = each.value.compartment
  environment           = var.environment
  opsgenie_alert_arn    = var.opsgenie_alert_arn
  ocimon_alarms_enabled = each.value.resolved.ocimon_alarms_enabled
  destinations          = [var.notification_topic_ocid]

  is_enabled_ocimon_pdb_tablespace_utilization   = false
  is_enabled_ocimon_pdb_storage_utilization      = false
  is_enabled_ocimon_pdb_processes_utilization    = false
  is_enabled_ocimon_pdb_user_password_expiration = false
  is_enabled_ocimon_pdb_cpu_utilization          = false
  is_enabled_ocimon_pdb_blocking_sessions_count  = false

  depends_on = [data.terraform_remote_state.databases]
}

# OCI Monitoring PDB (exa3)
module "ocimon_pdb_monitoring_exa3" {
  for_each = local.exa3_pdbs

  source                = "../../../modules/ocimon/pdb_monitoring"
  exainfra_id           = local.exa3.exainfra_id
  exainfra_ocid         = local.exa3.exainfra_ocid
  vm_cluster_id         = local.exa3.vm_cluster_id
  vm_cluster_name       = local.exa3.vm_cluster_name
  vm_cluster_ocid       = local.exa3.vm_cluster_ocid
  database_name         = each.value.name
  database_ocid         = each.value.ocid
  compartment_ocid      = each.value.compartment
  environment           = var.environment
  opsgenie_alert_arn    = var.opsgenie_alert_arn
  ocimon_alarms_enabled = each.value.resolved.ocimon_alarms_enabled
  destinations          = [var.notification_topic_ocid]

  is_enabled_ocimon_pdb_tablespace_utilization   = false
  is_enabled_ocimon_pdb_storage_utilization      = false
  is_enabled_ocimon_pdb_processes_utilization    = false
  is_enabled_ocimon_pdb_user_password_expiration = false
  is_enabled_ocimon_pdb_cpu_utilization          = false
  is_enabled_ocimon_pdb_blocking_sessions_count  = false

  depends_on = [data.terraform_remote_state.databases]
}

# ========================================
# LOG ANALYTICS ENTITIES
# ========================================
# Log analytics entities per DB Node per CDB across all 3 PRD clusters.
# Entities are created in the example_monitor_prd monitoring compartment
# (local.monitor_compartment_ocid) and each is associated to its cluster's
# pre-existing log group in the 609 resource-anchor compartment (the
# association passes the log-group compartment, local.la_log_group_compartment).
#
# CRITICAL: each entity MUST be backed by its DB node's Management Agent
# (management_agent_id). The DBAlertLogSource association is a file-based log
# source, which the OCI UpsertAssociations API only accepts for agent-backed
# entities. Agentless entities fail with 400-InvalidParameter "Entity is either
# not ready for association or not in the passed in compartment" — this was the
# cause of the earlier prd association failures. Agents are resolved by matching
# each node's FQDN to the agent whose `host` is that FQDN (see la_agent_by_host).
#
# Cluster → Log Group mapping:
#   exa1 (exa1vmc1) → LG_PRD_ODBAWS_EXA1VMC1
#   exa2 (exa2vmc1) → LG_PRD_ODBAWS_EXA2VMC1
#   exa3 (exa3vmc1) → LG_PRD_ODBAWS_EXA3VMC1
# ========================================

# Management Agents (one per DB node) live in the 609 resource-anchor
# compartment. Used to back each LA entity so file-source associations succeed.
data "oci_management_agent_management_agents" "la" {
  count          = var.enable_log_analytics ? 1 : 0
  compartment_id = local.la_log_group_compartment
}

locals {
  # 609 compartment that owns the pre-existing per-cluster log groups.
  la_log_group_compartment = "ocid1.compartment.oc1..exampleuniqueidcompar0001"

  # Per-cluster log group OCIDs (pre-existing, in the 609 compartment).
  la_log_groups = {
    exa1 = "ocid1.loganalyticsloggroup.oc1.iad.exampleuniqueidlogana0002"
    exa2 = "ocid1.loganalyticsloggroup.oc1.iad.exampleuniqueidlogana0003"
    exa3 = "ocid1.loganalyticsloggroup.oc1.iad.exampleuniqueidlogana0004"
  }

  # Management-agent hostname -> OCID map. A DBAlertLogSource (file-based)
  # namespace association requires the LA entity to be backed by a Management
  # Agent; agentless entities fail UpsertAssociations with
  # "Entity is either not ready for association or not in the passed in
  # compartment". Each DB node has an agent named "<hostname>-mgmt-agent" whose
  # `host` attribute is the FQDN "<hostname>.client.example.oraclevcn.com".
  la_agent_by_host = var.enable_log_analytics ? {
    for a in data.oci_management_agent_management_agents.la[0].management_agents :
    a.host => a.id
  } : {}

  # DB nodes per cluster
  la_exa1_db_nodes = try(local.exa1.db_nodes.db_nodes, [])
  la_exa2_db_nodes = try(local.exa2.db_nodes.db_nodes, [])
  la_exa3_db_nodes = try(local.exa3.db_nodes.db_nodes, [])

  # CDB maps per cluster (exclude reporting/template)
  la_exa1_eligible = { for k, v in local.exa1_cdbs : k => v if lookup(v, "role", "regular") != "reporting" }
  la_exa2_eligible = { for k, v in local.exa2_cdbs : k => v if lookup(v, "role", "regular") != "reporting" }
  la_exa3_eligible = { for k, v in local.exa3_cdbs : k => v if lookup(v, "role", "regular") != "reporting" }

  # Cross-product per cluster
  la_exa1_entities = {
    for pair in setproduct(keys(local.la_exa1_eligible), range(length(local.la_exa1_db_nodes))) :
    "${local.la_exa1_eligible[pair[0]].name}-${try(local.la_exa1_db_nodes[pair[1]].hostname, "node${pair[1] + 1}")}" => {
      cdb_name      = local.la_exa1_eligible[pair[0]].name
      cluster_name  = local.exa1.vm_cluster_name
      node_index    = pair[1]
      node_hostname = try(local.la_exa1_db_nodes[pair[1]].hostname, null)
      log_group_id  = local.la_log_groups["exa1"]
      instance_num  = substr(try(local.la_exa1_db_nodes[pair[1]].hostname, tostring(pair[1] + 1)), -1, 1)
      management_agent_id = try(
        local.la_agent_by_host["${local.la_exa1_db_nodes[pair[1]].hostname}.client.example.oraclevcn.com"],
        null
      )
    }
  }

  la_exa2_entities = {
    for pair in setproduct(keys(local.la_exa2_eligible), range(length(local.la_exa2_db_nodes))) :
    "${local.la_exa2_eligible[pair[0]].name}-${try(local.la_exa2_db_nodes[pair[1]].hostname, "node${pair[1] + 1}")}" => {
      cdb_name      = local.la_exa2_eligible[pair[0]].name
      cluster_name  = local.exa2.vm_cluster_name
      node_index    = pair[1]
      node_hostname = try(local.la_exa2_db_nodes[pair[1]].hostname, null)
      log_group_id  = local.la_log_groups["exa2"]
      instance_num  = substr(try(local.la_exa2_db_nodes[pair[1]].hostname, tostring(pair[1] + 1)), -1, 1)
      management_agent_id = try(
        local.la_agent_by_host["${local.la_exa2_db_nodes[pair[1]].hostname}.client.example.oraclevcn.com"],
        null
      )
    }
  }

  la_exa3_entities = {
    for pair in setproduct(keys(local.la_exa3_eligible), range(length(local.la_exa3_db_nodes))) :
    "${local.la_exa3_eligible[pair[0]].name}-${try(local.la_exa3_db_nodes[pair[1]].hostname, "node${pair[1] + 1}")}" => {
      cdb_name      = local.la_exa3_eligible[pair[0]].name
      cluster_name  = local.exa3.vm_cluster_name
      node_index    = pair[1]
      node_hostname = try(local.la_exa3_db_nodes[pair[1]].hostname, null)
      log_group_id  = local.la_log_groups["exa3"]
      instance_num  = substr(try(local.la_exa3_db_nodes[pair[1]].hostname, tostring(pair[1] + 1)), -1, 1)
      management_agent_id = try(
        local.la_agent_by_host["${local.la_exa3_db_nodes[pair[1]].hostname}.client.example.oraclevcn.com"],
        null
      )
    }
  }

  # Merge all clusters into one map
  la_all_entities = merge(local.la_exa1_entities, local.la_exa2_entities, local.la_exa3_entities)
}

module "log_analytics_entity" {
  source   = "../../../modules/oci-log-analytics-entity"
  for_each = var.enable_log_analytics ? local.la_all_entities : {}

  namespace = var.log_analytics_namespace
  # LA entities must co-locate with their Management Agent, log group, and the
  # association call — all in the 609 resource-anchor compartment. Placing the
  # entity in example_monitor_prd breaks UpsertAssociations even when agent-backed.
  # (CloudWatch/OCI alarms and dashboards still live in example_monitor_prd; only
  # the LA entities live in 609.)
  compartment_id      = local.la_log_group_compartment
  name                = each.key
  entity_type_name    = "Oracle Database Instance"
  timezone_region     = "America/Chicago"
  management_agent_id = each.value.management_agent_id

  properties = {
    "adr_home"        = "/u02/app/oracle/diag/rdbms/${each.value.cdb_name}_${each.value.cluster_name}/${each.value.cdb_name}${each.value.instance_num}"
    "audit_dest"      = ""
    "host_name"       = try("${each.value.node_hostname}.client.example.oraclevcn.com", "")
    "oracle_home"     = "/u02/app/oracle/product/19.0.0.0/dbhome_1"
    "port"            = "1521"
    "service_name"    = "ORCL"
    "sid"             = "ORCL"
    "DIAGNOSTIC_DEST" = "/u02/app/oracle"
    "AUDIT_FILE_DEST" = "/u02/app/oracle/admin/ORCL/adump"
  }

  source_associations = [
    {
      source_name    = "DBAlertLogSource"
      log_group_id   = each.value.log_group_id
      compartment_id = local.la_log_group_compartment
    }
  ]

  freeform_tags = merge(var.tags, {
    "cdb_name"    = each.value.cdb_name
    "cluster"     = each.value.cluster_name
    "node_number" = each.value.instance_num
    "Environment" = var.environment
  })
}

# ========================================
# CUSTOM NAMESPACE ALARMS (example_oracledb_aws) — per PRD cluster
# ========================================
# Alarms for the custom metrics emitted by the oci-functions PRD functions
# (one per cluster): libcache_waiting_sessions (per RAC instance, P4>10/P3>50),
# sshstatus (per node), oracle_service_status (per service name). Routed to the
# same ONS topic. Held off by default (enable_custom_metric_alarms) until the
# PRD functions are healthy (ocimon on PDB008, port 22 on the DB nodes).

module "custom_metrics_monitoring_exa1" {
  count = var.enable_custom_metric_alarms && local.exa1.vm_cluster_id != "" ? 1 : 0

  source           = "../../../modules/ocimon/custom_metrics_monitoring"
  exainfra_id      = local.exa1.exainfra_id
  vm_cluster_id    = local.exa1.vm_cluster_id
  vm_cluster_name  = local.exa1.vm_cluster_name
  compartment_ocid = local.monitor_compartment_ocid
  environment      = var.environment
  destinations     = [var.notification_topic_ocid]

  ocimon_alarms_enabled = true
  is_enabled_sshstatus  = true
  # No reporting PDBs on e1c1: oracle_service_status is monitored per reporting
  # PDB on e3c1 only.
  is_enabled_oracle_service_status     = false
  oracle_service_databases             = []
  is_enabled_libcache_waiting_sessions = true
  libcache_databases                   = local.libcache_alarm_databases_exa1
  libcache_warning_threshold           = var.libcache_warning_threshold
  libcache_critical_threshold          = var.libcache_critical_threshold

  in_downtime      = var.in_downtime
  support_category = var.support_category
  support_teams    = var.support_teams
  tag_team         = var.tag_team
  tag_created_by   = var.tag_created_by
  tags             = merge(var.tags, { "Environment" : var.environment })

  depends_on = [data.terraform_remote_state.compute]
}

module "custom_metrics_monitoring_exa2" {
  count = var.enable_custom_metric_alarms && local.exa2.vm_cluster_id != "" ? 1 : 0

  source           = "../../../modules/ocimon/custom_metrics_monitoring"
  exainfra_id      = local.exa2.exainfra_id
  vm_cluster_id    = local.exa2.vm_cluster_id
  vm_cluster_name  = local.exa2.vm_cluster_name
  compartment_ocid = local.monitor_compartment_ocid
  environment      = var.environment
  destinations     = [var.notification_topic_ocid]

  ocimon_alarms_enabled = true
  is_enabled_sshstatus  = true
  # No reporting PDBs on e2c1: oracle_service_status is monitored per reporting
  # PDB on e3c1 only.
  is_enabled_oracle_service_status     = false
  oracle_service_databases             = []
  is_enabled_libcache_waiting_sessions = true
  libcache_databases                   = local.libcache_alarm_databases_exa2
  libcache_warning_threshold           = var.libcache_warning_threshold
  libcache_critical_threshold          = var.libcache_critical_threshold

  in_downtime      = var.in_downtime
  support_category = var.support_category
  support_teams    = var.support_teams
  tag_team         = var.tag_team
  tag_created_by   = var.tag_created_by
  tags             = merge(var.tags, { "Environment" : var.environment })

  depends_on = [data.terraform_remote_state.compute]
}

module "custom_metrics_monitoring_exa3" {
  count = var.enable_custom_metric_alarms && local.exa3.vm_cluster_id != "" ? 1 : 0

  source           = "../../../modules/ocimon/custom_metrics_monitoring"
  exainfra_id      = local.exa3.exainfra_id
  vm_cluster_id    = local.exa3.vm_cluster_id
  vm_cluster_name  = local.exa3.vm_cluster_name
  compartment_ocid = local.monitor_compartment_ocid
  environment      = var.environment
  destinations     = [var.notification_topic_ocid]

  # e3c1 (exa3): no libcache check per the DBA (no ocimon, libcache function
  # not deployed there), so the libcache alarm is disabled. sshstatus stays on.
  # Service status is monitored PER REPORTING PDB (<cluster>-<pdb>-reporting-
  # service-status) and PER CPH SERVICE on the standbys (<cluster>-<service>-
  # service-status); see oracle_service_databases.tf. The old per-service
  # oracle_service_status alarms are replaced by these.
  ocimon_alarms_enabled                = true
  is_enabled_sshstatus                 = true
  is_enabled_oracle_service_status     = false
  oracle_service_databases             = []
  reporting_service_databases          = local.reporting_service_alarm_databases_exa3
  cph_services                         = var.cph_services
  is_enabled_libcache_waiting_sessions = false
  libcache_warning_threshold           = var.libcache_warning_threshold
  libcache_critical_threshold          = var.libcache_critical_threshold

  in_downtime      = var.in_downtime
  support_category = var.support_category
  support_teams    = var.support_teams
  tag_team         = var.tag_team
  tag_created_by   = var.tag_created_by
  tags             = merge(var.tags, { "Environment" : var.environment })

  depends_on = [data.terraform_remote_state.compute]
}
