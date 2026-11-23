# ---------------------------------------------------------------------------
# Locals: resolve compute outputs from remote state.
# var.* values take precedence when explicitly set (non-null).
#
# The single-cluster locals below feed the legacy global dashboards
# (cluster_dashboard / cdb_dashboard / pdb_dashboard) and default to the exa2
# (ExaProd2) cluster. Override via var.exainfra_id / var.vm_cluster_id etc.
# ---------------------------------------------------------------------------
locals {
  exainfra_id     = coalesce(var.exainfra_id, try(data.terraform_remote_state.compute.outputs.exa2_exainfra_id, null))
  exainfra_ocid   = coalesce(var.exainfra_ocid, try(data.terraform_remote_state.compute.outputs.exa2_exainfra_ocid, null))
  vm_cluster_id   = coalesce(var.vm_cluster_id, try(data.terraform_remote_state.compute.outputs.exa2_vm_cluster_id, null))
  vm_cluster_name = coalesce(var.vm_cluster_name, try(data.terraform_remote_state.compute.outputs.exa2_vm_cluster_name, null))
  vm_cluster_ocid = coalesce(var.vm_cluster_ocid, try(data.terraform_remote_state.compute.outputs.exa2_vm_cluster_ocid, null))
}

# ---------------------------------------------------------------------------
# Multi-cluster resolution for the individual per-DB dashboards.
# Merges each entry in var.clusters with the matching 2_compute remote-state
# outputs (exa1_* / exa2_* / exa3_*), producing a map ready for for_each.
# ---------------------------------------------------------------------------
locals {
  compute_outputs = data.terraform_remote_state.compute.outputs

  # Clusters are derived from state: a cluster exists when 2_compute exports its
  # <key>_vm_cluster_id. var.clusters is NOT required (CI has no tfvars); its
  # lists are only a fallback when the 3_databases state has no names yet.
  clusters_resolved = {
    for key in ["exa1", "exa2", "exa3"] : key => {
      exainfra_id     = local.compute_outputs["${key}_exainfra_id"]
      exainfra_ocid   = local.compute_outputs["${key}_exainfra_ocid"]
      vm_cluster_id   = local.compute_outputs["${key}_vm_cluster_id"]
      vm_cluster_name = local.compute_outputs["${key}_vm_cluster_name"]
      vm_cluster_ocid = local.compute_outputs["${key}_vm_cluster_ocid"]
      cdb_databases   = length(local.oci_clusters[key].cdb_names) > 0 ? sort(local.oci_clusters[key].cdb_names) : try(var.clusters[key].cdb_databases, [])
      pdb_databases   = length(local.oci_clusters[key].pdb_names) > 0 ? sort(local.oci_clusters[key].pdb_names) : try(var.clusters[key].pdb_databases, [])
    }
    if contains(keys(local.compute_outputs), "${key}_vm_cluster_id")
  }
}

# ---------------------------------------------------------------------------
# OCI-side dashboards: per-cluster database OCID maps.
#
# IMPORTANT: source from the per-cluster databases_exa{1,2,3} outputs, NOT the
# merged 3_databases cdbs/pdbs maps. The merged maps are keyed by database name
# and merge()'d across clusters, so a DB name present on multiple clusters
# (e.g. cdb006) collides and only one cluster's OCID survives. Iterating each
# cluster separately keeps every database and its correct OCID + cluster name.
#
# monitor_compartment_ocid comes from bootstrap. try() tolerates the outputs
# not yet existing in state (empty map => zero dashboards, no hard failure).
# ---------------------------------------------------------------------------
locals {
  monitor_compartment_ocid = data.terraform_remote_state.bootstrap.outputs.monitor_compartment_ocid

  db_outputs = try(data.terraform_remote_state.databases.outputs, {})

  # Per-cluster resolved config for the OCI dashboards: vm cluster name (for
  # dashboard naming) + name => OCID maps for CDBs and PDBs.
  oci_clusters = {
    for key in ["exa1", "exa2", "exa3"] : key => {
      vm_cluster_name = try(local.compute_outputs["${key}_vm_cluster_name"], "")
      # OCI dashboards: one dashboard per DB, keyed by the OUTPUT MAP KEY
      # (already unique per cluster) -> OCID. Do NOT key by db.name: some DB
      # names repeat within a cluster (PDB040 on cdb040 and cdb042,
      # PDB015 on cdb012 and cdb501), which the source maps disambiguate
      # with compound keys (e.g. pdb001). Keying by db.name would
      # collide ("Duplicate object key") and produce duplicate dashboard IDs.
      cdb_ocids = {
        for name, db in try(local.db_outputs["databases_${key}"].cdbs, {}) : name => db.ocid
      }
      pdb_ocids = {
        for name, db in try(local.db_outputs["databases_${key}"].pdbs, {}) : name => db.ocid
      }
      # CloudWatch individual dashboards need the REAL DB names (matching the
      # Metrics Insights resourceName dimension), de-duplicated. Derived from
      # the db.name values, not the (possibly compound) map keys.
      cdb_names = distinct([
        for name, db in try(local.db_outputs["databases_${key}"].cdbs, {}) : db.name
      ])
      pdb_names = distinct([
        for name, db in try(local.db_outputs["databases_${key}"].pdbs, {}) : db.name
      ])
    }
  }
}


