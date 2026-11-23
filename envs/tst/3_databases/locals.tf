# ---------------------------------------------------------------------------
# Locals: resolve compute outputs from remote state.
# var.* values take precedence when explicitly set (non-null) to allow
# manual override without re-running 2_compute.
# ---------------------------------------------------------------------------
locals {
  exainfra_id     = coalesce(var.exainfra_id, data.terraform_remote_state.compute.outputs.exainfra_id)
  exainfra_ocid   = coalesce(var.exainfra_ocid, data.terraform_remote_state.compute.outputs.exainfra_ocid)
  vm_cluster_id   = coalesce(var.vm_cluster_id, data.terraform_remote_state.compute.outputs.vm_cluster_id)
  vm_cluster_name = coalesce(var.vm_cluster_name, data.terraform_remote_state.compute.outputs.vm_cluster_name)
  vm_cluster_ocid = coalesce(var.vm_cluster_ocid, data.terraform_remote_state.compute.outputs.vm_cluster_ocid)
}

