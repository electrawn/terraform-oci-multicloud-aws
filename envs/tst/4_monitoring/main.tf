# =========================================================================
# 4_monitoring — Dedicated Monitoring Stage
# =========================================================================
# This stage extracts and centralizes all monitoring resources:
#   - Compute infrastructure alarms (CloudWatch cluster and db_server)
#   - Database-specific alarms (CloudWatch and OCI Monitoring for CDBs and PDBs)
#
# Remote State Dependencies:
#   - 2_compute: Provides exainfra_id, vm_cluster_id, and related metadata
#   - 3_databases: Provides CDB and PDB resource IDs and metadata
# =========================================================================

# ========================
# Local Variables
# ========================
locals {
  # Compute infrastructure outputs from 2_compute stage
  exainfra_id      = data.terraform_remote_state.compute.outputs.exainfra_id
  exainfra_ocid    = data.terraform_remote_state.compute.outputs.exainfra_ocid
  vm_cluster_id    = data.terraform_remote_state.compute.outputs.vm_cluster_id
  vm_cluster_name  = data.terraform_remote_state.compute.outputs.vm_cluster_name
  vm_cluster_ocid  = data.terraform_remote_state.compute.outputs.vm_cluster_ocid
  compartment_ocid = try(data.terraform_remote_state.bootstrap.outputs.monitor_compartment_ocid, try(data.terraform_remote_state.compute.outputs.compartment_ocid, null))

  # Prefer newer compute outputs; gracefully degrade for older state.
  exainfra_name          = try(data.terraform_remote_state.compute.outputs.exainfra_display_name, local.vm_cluster_name)
  aws_exainfra_dbservers = try(data.terraform_remote_state.compute.outputs.db_servers, null)
  aws_vmcluster_dbnodes  = try(data.terraform_remote_state.compute.outputs.db_nodes, null)
  db_server_ids = try(
    [for s in local.aws_exainfra_dbservers.db_servers : s.id],
    try([for s in local.aws_exainfra_dbservers : s.id], [])
  )
  enable_db_server_monitoring = local.aws_exainfra_dbservers != null && local.aws_vmcluster_dbnodes != null && try(length(local.db_server_ids) > 0, false)

  # Prefer aggregated DB maps; rebuild from legacy per-DB outputs if absent.
  cdbs = local.cdbs_remote
  pdbs = local.pdbs_remote

  cdbs_remote = try(
    data.terraform_remote_state.databases.outputs.cdbs,
    {
      for output_name, db_ocid in data.terraform_remote_state.databases.outputs :
      replace(output_name, "_cdb_id", "") => {
        name           = replace(output_name, "_cdb_id", "")
        ocid           = db_ocid
        compartment    = local.compartment_ocid
        alarms_enabled = true
      }
      if can(regex("_cdb_id$", output_name))
    }
  )

  pdbs_remote = try(
    data.terraform_remote_state.databases.outputs.pdbs,
    {
      for output_name, db_ocid in data.terraform_remote_state.databases.outputs :
      replace(output_name, "_id", "") => {
        name           = split("_pdb", output_name)[0]
        ocid           = db_ocid
        compartment    = local.compartment_ocid
        alarms_enabled = true
      }
      if can(regex("_pdb(_[0-9]+)?_id$", output_name))
    }
  )

  # Role configuration map — single source of truth for role-to-feature-toggle mappings.
  # Each role defines which monitoring and management features are enabled.
  # NOTE: Only Data Guard alarms (apply_lag, transport_lag) are enabled on OCI Monitoring.
  #       All other ocimon alarms are disabled — CloudWatch covers those metrics.
  role_config = {
    template = {
      enable_db_management            = true
      alarms_enabled                  = false
      ocimon_alarms_enabled           = false
      is_enabled_ocimon_apply_lag     = false
      is_enabled_ocimon_transport_lag = false
    }
    regular = {
      enable_db_management            = true
      alarms_enabled                  = true
      ocimon_alarms_enabled           = false
      is_enabled_ocimon_apply_lag     = false
      is_enabled_ocimon_transport_lag = false
    }
    dataguard_primary = {
      enable_db_management            = true
      alarms_enabled                  = true
      ocimon_alarms_enabled           = true
      is_enabled_ocimon_apply_lag     = true
      is_enabled_ocimon_transport_lag = true
    }
    dataguard_standby = {
      enable_db_management            = true
      alarms_enabled                  = true
      ocimon_alarms_enabled           = true
      is_enabled_ocimon_apply_lag     = true
      is_enabled_ocimon_transport_lag = true
    }
    reporting = {
      enable_db_management            = false
      alarms_enabled                  = false
      ocimon_alarms_enabled           = false
      is_enabled_ocimon_apply_lag     = false
      is_enabled_ocimon_transport_lag = false
    }
  }

  # Enrich CDB map with resolved role config.
  # Uses lookup with "regular" default to handle missing or null role fields for backward compatibility.
  cdbs_with_config = {
    for name, cdb in local.cdbs : name => merge(cdb, {
      resolved = local.role_config[lookup(cdb, "role", "regular")]
    })
  }

  # Enrich PDB map with resolved role config.
  # Uses lookup with "regular" default to handle missing or null role fields for backward compatibility.
  pdbs_with_config = {
    for name, pdb in local.pdbs : name => merge(pdb, {
      resolved = local.role_config[lookup(pdb, "role", "regular")]
    })
  }
}

# ========================================
# COMPUTE INFRASTRUCTURE MONITORING
# ========================================

# CloudWatch Cluster-level monitoring
module "cloudwatch_cluster_monitoring" {
  source             = "../../../modules/cloudwatch/cluster_monitoring"
  exainfra_id        = local.exainfra_id
  vm_cluster_id      = local.vm_cluster_id
  environment        = var.environment
  opsgenie_alert_arn = var.opsgenie_alert_arn
  in_downtime        = var.in_downtime
  support_category   = var.support_category
  support_teams      = var.support_teams

  depends_on = [data.terraform_remote_state.compute]
}

# CloudWatch DB Server monitoring
module "cloudwatch_db_server_monitoring" {
  count = local.enable_db_server_monitoring ? 1 : 0

  source                 = "../../../modules/cloudwatch/db_server_monitoring"
  exainfra_id            = local.exainfra_id
  exainfra_name          = local.exainfra_name
  exainfra_ocid          = local.exainfra_ocid
  db_servers             = local.db_server_ids
  aws_exainfra_dbservers = local.aws_exainfra_dbservers
  vm_cluster_name        = local.vm_cluster_name
  vm_cluster_id          = local.vm_cluster_id
  vm_cluster_ocid        = local.vm_cluster_ocid
  aws_vmcluster_dbnodes  = local.aws_vmcluster_dbnodes
  environment            = var.environment
  opsgenie_alert_arn     = var.opsgenie_alert_arn
  in_downtime            = var.in_downtime
  support_category       = var.support_category
  support_teams          = var.support_teams

  depends_on = [data.terraform_remote_state.compute]
}

# ========================================
# DATABASE MONITORING - CloudWatch CDB
# ========================================
module "cloudwatch_cdb_monitoring" {
  for_each = local.cdbs_with_config

  source             = "../../../modules/cloudwatch/cdb_monitoring"
  exainfra_id        = local.exainfra_id
  exainfra_ocid      = local.exainfra_ocid
  vm_cluster_id      = local.vm_cluster_id
  vm_cluster_name    = local.vm_cluster_name
  vm_cluster_ocid    = local.vm_cluster_ocid
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
# DATABASE MONITORING - OCI Monitoring CDB
# ========================================
module "ocimon_cdb_monitoring" {
  for_each = local.cdbs_with_config

  source                = "../../../modules/ocimon/cdb_monitoring"
  exainfra_id           = local.exainfra_id
  exainfra_ocid         = local.exainfra_ocid
  vm_cluster_id         = local.vm_cluster_id
  vm_cluster_name       = local.vm_cluster_name
  vm_cluster_ocid       = local.vm_cluster_ocid
  database_name         = each.value.name
  database_ocid         = each.value.ocid
  compartment_ocid      = each.value.compartment
  environment           = var.environment
  opsgenie_alert_arn    = var.opsgenie_alert_arn
  ocimon_alarms_enabled = each.value.resolved.ocimon_alarms_enabled
  destinations          = [var.notification_topic_ocid]

  # All non-DG ocimon alarms disabled — CloudWatch covers these metrics
  is_enabled_ocimon_cdb_tablespace_utilization          = false
  is_enabled_ocimon_cdb_storage_utilization             = false
  is_enabled_ocimon_cdb_processes_utilization           = false
  is_enabled_ocimon_cdb_user_password_expiration        = false
  is_enabled_ocimon_cdb_cpu_utilization                 = false
  is_enabled_ocimon_cdb_flash_recovery_area_utilization = false
  is_enabled_ocimon_cdb_backup_status_failed            = false
  # Data Guard specific — only enabled for dataguard_* roles
  is_enabled_ocimon_cdb_apply_lag     = each.value.resolved.is_enabled_ocimon_apply_lag
  is_enabled_ocimon_cdb_transport_lag = each.value.resolved.is_enabled_ocimon_transport_lag

  depends_on = [data.terraform_remote_state.databases]
}

# ========================================
# DATABASE MONITORING - CloudWatch PDB
# ========================================
module "cloudwatch_pdb_monitoring" {
  for_each = local.pdbs_with_config

  source             = "../../../modules/cloudwatch/pdb_monitoring"
  exainfra_id        = local.exainfra_id
  exainfra_ocid      = local.exainfra_ocid
  vm_cluster_id      = local.vm_cluster_id
  vm_cluster_name    = local.vm_cluster_name
  vm_cluster_ocid    = local.vm_cluster_ocid
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
# DATABASE MONITORING - OCI Monitoring PDB
# ========================================
module "ocimon_pdb_monitoring" {
  for_each = local.pdbs_with_config

  source                = "../../../modules/ocimon/pdb_monitoring"
  exainfra_id           = local.exainfra_id
  exainfra_ocid         = local.exainfra_ocid
  vm_cluster_id         = local.vm_cluster_id
  vm_cluster_name       = local.vm_cluster_name
  vm_cluster_ocid       = local.vm_cluster_ocid
  database_name         = each.value.name
  database_ocid         = each.value.ocid
  compartment_ocid      = each.value.compartment
  environment           = var.environment
  opsgenie_alert_arn    = var.opsgenie_alert_arn
  ocimon_alarms_enabled = each.value.resolved.ocimon_alarms_enabled
  destinations          = [var.notification_topic_ocid]

  # All ocimon PDB alarms disabled — CloudWatch covers these metrics
  is_enabled_ocimon_pdb_tablespace_utilization   = false
  is_enabled_ocimon_pdb_storage_utilization      = false
  is_enabled_ocimon_pdb_processes_utilization    = false
  is_enabled_ocimon_pdb_user_password_expiration = false
  is_enabled_ocimon_pdb_cpu_utilization          = false
  is_enabled_ocimon_pdb_blocking_sessions_count  = false

  depends_on = [data.terraform_remote_state.databases]
}

# ========================================
# CUSTOM NAMESPACE ALARMS (example_oracledb_aws)
# ========================================
# Alarms for the custom metrics emitted by the oci-functions project (TST
# functions post to the monitor compartment, local.compartment_ocid):
#   - libcache_waiting_sessions (per RAC instance; warning P4 > 10, critical P3 > 50)
#   - sshstatus                 (per DB node, auto-discovered from the VM cluster)
#   - oracle_service_status     (per database service name)
# Same module and ONS topic as SBX.
module "custom_metrics_monitoring" {
  source = "../../../modules/ocimon/custom_metrics_monitoring"

  exainfra_id      = local.exainfra_id
  vm_cluster_id    = local.vm_cluster_id
  vm_cluster_name  = local.vm_cluster_name
  compartment_ocid = local.compartment_ocid
  environment      = var.environment
  destinations     = [var.notification_topic_ocid]

  ocimon_alarms_enabled            = var.enable_custom_metric_alarms
  is_enabled_sshstatus             = true
  is_enabled_oracle_service_status = true
  oracle_service_databases         = var.oracle_service_databases

  is_enabled_libcache_waiting_sessions = true
  libcache_databases                   = local.libcache_alarm_databases
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

# ========================================
# LOG ANALYTICS ENTITIES
# ========================================
# Log analytics entities are created per DB Node per CDB to enable log
# ingestion from Oracle Database instances.
#
# Entity naming: {cdb_name}-{hostname}
# All entities use the shared cluster log group: LG_DEV_ODBAWS_exa1vmc1
# ========================================

locals {
  # DB node list from compute (graceful degradation if not yet available)
  la_db_nodes = try(local.aws_vmcluster_dbnodes.db_nodes, [])

  # Cluster name for hostname construction
  la_cluster_name = local.vm_cluster_name

  # Shared log group for all tst LA entities (in the 609 compartment).
  # la_log_group_compartment documents where it lives; associations are
  # created in the entity compartment (local.compartment_ocid), see below.
  la_log_group_id          = "ocid1.loganalyticsloggroup.oc1.iad.exampleuniqueidlogana0001"
  la_log_group_compartment = "ocid1.compartment.oc1..exampleuniqueidcompar0001"

  # Management agent OCIDs per node (from OCI management agents on each db node)
  la_management_agents = {
    0 = "ocid1.managementagent.oc1.iad.exampleuniqueidmanage0001"
    1 = "ocid1.managementagent.oc1.iad.exampleuniqueidmanage0002"
  }

  # CDBs adopted into 3_databases state on 2026-11-13 (state-only import)
  # whose log ingestion is not yet confirmed in scope; same list as
  # 5_dashboards dashboard_pending_scope. Remove a name to create its entities.
  la_pending_scope = ["cdb001", "cdb002", "cdb065", "cdb050", "cdb024", "cdb075"]

  # Map of CDBs to enable log analytics for.
  # Exclude cdb069 — already configured and working outside Terraform.
  la_enabled_cdbs = {
    for name, cdb in local.cdbs : name => cdb
    if lookup(cdb, "role", "regular") != "reporting" && name != "cdb069" && !contains(local.la_pending_scope, name)
  }

  # Cross-product: one entity per CDB per node
  log_analytics_entities = {
    for pair in setproduct(keys(local.la_enabled_cdbs), range(length(local.la_db_nodes))) :
    "${local.la_enabled_cdbs[pair[0]].name}-${try(local.la_db_nodes[pair[1]].hostname, "node${pair[1] + 1}")}" => {
      cdb_name         = local.la_enabled_cdbs[pair[0]].name
      compartment      = local.la_enabled_cdbs[pair[0]].compartment
      node_index       = pair[1]
      node_hostname    = try(local.la_db_nodes[pair[1]].hostname, null)
      management_agent = lookup(local.la_management_agents, pair[1], null)
      properties = {
        "adr_home"        = "/u02/app/oracle/diag/rdbms/${local.la_enabled_cdbs[pair[0]].name}_${local.la_cluster_name}/${local.la_enabled_cdbs[pair[0]].name}${substr(try(local.la_db_nodes[pair[1]].hostname, tostring(pair[1] + 1)), -1, 1)}"
        "audit_dest"      = ""
        "host_name"       = try("${local.la_db_nodes[pair[1]].hostname}.client.example.oraclevcn.com", "")
        "oracle_home"     = "/u02/app/oracle/product/19.0.0.0/dbhome_1"
        "port"            = "1521"
        "service_name"    = "ORCL"
        "sid"             = "ORCL"
        "DIAGNOSTIC_DEST" = "/u02/app/oracle"
        "AUDIT_FILE_DEST" = "/u02/app/oracle/admin/ORCL/adump"
      }
    }
  }
}

# ========================================
# LOG ANALYTICS ENTITIES
# ========================================
module "log_analytics_entity" {
  source   = "../../../modules/oci-log-analytics-entity"
  for_each = var.enable_log_analytics ? local.log_analytics_entities : {}

  namespace           = var.log_analytics_namespace
  compartment_id      = local.compartment_ocid
  name                = each.key
  entity_type_name    = "Oracle Database Instance"
  management_agent_id = each.value.management_agent
  timezone_region     = "America/Chicago"
  properties          = each.value.properties

  source_associations = [
    {
      source_name  = "DBAlertLogSource"
      log_group_id = local.la_log_group_id
      # The association's compartment must be the ENTITY's compartment
      # (OCI: "The entity should belong to the specified input compartment").
      # The log group itself may live elsewhere (609 compartment).
      compartment_id = local.compartment_ocid
    }
  ]

  freeform_tags = merge(var.tags, {
    "cdb_name"    = each.value.cdb_name
    "node_number" = tostring(each.value.node_index + 1)
    "Environment" = var.environment
  })
}
