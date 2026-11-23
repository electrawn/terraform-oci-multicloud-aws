# ---------------------------------------------------------------------------
# Locals: resolve compute outputs from remote state.
# var.* values take precedence when explicitly set (non-null).
# ---------------------------------------------------------------------------
locals {
  exainfra_id     = coalesce(var.exainfra_id, data.terraform_remote_state.compute.outputs.exainfra_id)
  exainfra_ocid   = coalesce(var.exainfra_ocid, data.terraform_remote_state.compute.outputs.exainfra_ocid)
  vm_cluster_id   = coalesce(var.vm_cluster_id, data.terraform_remote_state.compute.outputs.vm_cluster_id)
  vm_cluster_name = coalesce(var.vm_cluster_name, data.terraform_remote_state.compute.outputs.vm_cluster_name)
  vm_cluster_ocid = coalesce(var.vm_cluster_ocid, data.terraform_remote_state.compute.outputs.vm_cluster_ocid)

  # Compartment for OCI-side dashboards, from bootstrap.
  monitor_compartment_ocid = data.terraform_remote_state.bootstrap.outputs.monitor_compartment_ocid

  # OCI-side dashboards key metric queries on the database OCID (resourceId).
  # Build name => OCID maps from the 3_databases cdbs/pdbs outputs.
  # try(..., {}) tolerates the outputs not yet existing in state.
  #
  # dashboard_pending_scope: databases adopted into 3_databases state on
  # 2026-11-13 (state-only import) whose monitoring is not yet confirmed in
  # scope. They are kept off the per-database dashboards until confirmed;
  # remove a name here to add its dashboards.
  dashboard_pending_scope = [
    "cdb001", "cdb002", "cdb065", "cdb050", "cdb024", "cdb075",
    "PDB004", "PDB005", "PDB003", "PDB050", "PDB024", "PDB070",
  ]
  cdb_ocids = {
    for name, db in try(data.terraform_remote_state.databases.outputs.cdbs, {}) : db.name => db.ocid
    if !contains(local.dashboard_pending_scope, db.name)
  }
  pdb_ocids = {
    for name, db in try(data.terraform_remote_state.databases.outputs.pdbs, {}) : db.name => db.ocid
    if !contains(local.dashboard_pending_scope, db.name)
  }
}

