locals {
  compute_outputs = try(data.terraform_remote_state.compute.outputs, {})

  exa1 = {
    exainfra_id   = lookup(local.compute_outputs, "exa1_exainfra_id", "")
    exainfra_ocid = lookup(local.compute_outputs, "exa1_exainfra_ocid", "")
    exainfra_name = lookup(local.compute_outputs, "exa1_exainfra_display_name", "")

    vm_cluster_id   = lookup(local.compute_outputs, "exa1_vm_cluster_id", "")
    vm_cluster_name = lookup(local.compute_outputs, "exa1_vm_cluster_name", "")
    vm_cluster_ocid = lookup(local.compute_outputs, "exa1_vm_cluster_ocid", "")

    db_servers = lookup(local.compute_outputs, "exa1_db_servers", null)
    db_nodes   = lookup(local.compute_outputs, "exa1_db_nodes", null)
  }

  exa2 = {
    exainfra_id   = lookup(local.compute_outputs, "exa2_exainfra_id", "")
    exainfra_ocid = lookup(local.compute_outputs, "exa2_exainfra_ocid", "")
    exainfra_name = lookup(local.compute_outputs, "exa2_exainfra_display_name", "")

    vm_cluster_id   = lookup(local.compute_outputs, "exa2_vm_cluster_id", "")
    vm_cluster_name = lookup(local.compute_outputs, "exa2_vm_cluster_name", "")
    vm_cluster_ocid = lookup(local.compute_outputs, "exa2_vm_cluster_ocid", "")

    db_servers = lookup(local.compute_outputs, "exa2_db_servers", null)
    db_nodes   = lookup(local.compute_outputs, "exa2_db_nodes", null)
  }

  exa3 = {
    exainfra_id   = lookup(local.compute_outputs, "exa3_exainfra_id", "")
    exainfra_ocid = lookup(local.compute_outputs, "exa3_exainfra_ocid", "")
    exainfra_name = lookup(local.compute_outputs, "exa3_exainfra_display_name", "")

    vm_cluster_id   = lookup(local.compute_outputs, "exa3_vm_cluster_id", "")
    vm_cluster_name = lookup(local.compute_outputs, "exa3_vm_cluster_name", "")
    vm_cluster_ocid = lookup(local.compute_outputs, "exa3_vm_cluster_ocid", "")

    db_servers = lookup(local.compute_outputs, "exa3_db_servers", null)
    db_nodes   = lookup(local.compute_outputs, "exa3_db_nodes", null)
  }

  compartment_ocid = lookup(local.compute_outputs, "compartment_ocid", null)

  # Monitor compartment from bootstrap
  monitor_compartment_ocid = try(data.terraform_remote_state.bootstrap.outputs.monitor_compartment_ocid, local.compartment_ocid)

  # Guard: only create cluster-level monitoring when compute outputs are populated
  enable_cluster_monitoring = local.exa1.vm_cluster_id != "" && local.exa1.exainfra_id != ""

  # Role configuration map — single source of truth for role-to-feature-toggle mappings.
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

  # Per-cluster raw DB maps direct from each cluster's own 3_databases output.
  # IMPORTANT: source values from the cluster-specific outputs, NOT the merged
  # local.cdbs/local.pdbs maps. The root 3_databases `cdbs`/`pdbs` outputs are
  # merge()'d and keyed by database name, so when the same DB name exists on
  # more than one cluster (e.g. PDB039 on exa1 and exa3), the later cluster
  # clobbers the earlier one and every consumer would get the wrong OCID.
  exa1_cdbs_raw = try(data.terraform_remote_state.databases.outputs.databases_exa1.cdbs, {})
  exa2_cdbs_raw = try(data.terraform_remote_state.databases.outputs.databases_exa2.cdbs, {})
  exa3_cdbs_raw = try(data.terraform_remote_state.databases.outputs.databases_exa3.cdbs, {})

  exa1_pdbs_raw = try(data.terraform_remote_state.databases.outputs.databases_exa1.pdbs, {})
  exa2_pdbs_raw = try(data.terraform_remote_state.databases.outputs.databases_exa2.pdbs, {})
  exa3_pdbs_raw = try(data.terraform_remote_state.databases.outputs.databases_exa3.pdbs, {})

  # Per-cluster CDB maps (for cluster-specific alarm dimensions), each enriched
  # with resolved role config. Values come from the cluster-specific raw map.
  exa1_cdbs = { for k, v in local.exa1_cdbs_raw : k => merge(v, { resolved = local.role_config[lookup(v, "role", "regular")] }) }
  exa2_cdbs = { for k, v in local.exa2_cdbs_raw : k => merge(v, { resolved = local.role_config[lookup(v, "role", "regular")] }) }
  exa3_cdbs = { for k, v in local.exa3_cdbs_raw : k => merge(v, { resolved = local.role_config[lookup(v, "role", "regular")] }) }

  exa1_pdbs = { for k, v in local.exa1_pdbs_raw : k => merge(v, { resolved = local.role_config[lookup(v, "role", "regular")] }) }
  exa2_pdbs = { for k, v in local.exa2_pdbs_raw : k => merge(v, { resolved = local.role_config[lookup(v, "role", "regular")] }) }
  exa3_pdbs = { for k, v in local.exa3_pdbs_raw : k => merge(v, { resolved = local.role_config[lookup(v, "role", "regular")] }) }
}

check "compute_outputs_available_when_monitoring_enabled" {
  assert {
    condition     = !var.enable_monitoring_stage || length(local.compute_outputs) > 0
    error_message = "4_monitoring requires outputs from prd/2_compute state before enable_monitoring_stage=true. Run/apply 2_compute first so exa*_exainfra_* and exa*_vm_cluster_* outputs exist."
  }
}
