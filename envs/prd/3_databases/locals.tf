# ---------------------------------------------------------------------------
# Locals: resolve per-cluster compute outputs from remote state.
# var.exa*_* values take precedence when explicitly set (non-null).
# ---------------------------------------------------------------------------
locals {
  # exa1
  exa1_exainfra_id     = coalesce(var.exa1_exainfra_id, try(data.terraform_remote_state.compute.outputs.exa1_exainfra_id, null))
  exa1_exainfra_ocid   = coalesce(var.exa1_exainfra_ocid, try(data.terraform_remote_state.compute.outputs.exa1_exainfra_ocid, null))
  exa1_vm_cluster_id   = coalesce(var.exa1_vm_cluster_id, try(data.terraform_remote_state.compute.outputs.exa1_vm_cluster_id, null))
  exa1_vm_cluster_name = coalesce(var.exa1_vm_cluster_name, try(data.terraform_remote_state.compute.outputs.exa1_vm_cluster_name, null))
  exa1_vm_cluster_ocid = coalesce(var.exa1_vm_cluster_ocid, try(data.terraform_remote_state.compute.outputs.exa1_vm_cluster_ocid, null))

  # exa2
  exa2_exainfra_id     = coalesce(var.exa2_exainfra_id, try(data.terraform_remote_state.compute.outputs.exa2_exainfra_id, null))
  exa2_exainfra_ocid   = coalesce(var.exa2_exainfra_ocid, try(data.terraform_remote_state.compute.outputs.exa2_exainfra_ocid, null))
  exa2_vm_cluster_id   = coalesce(var.exa2_vm_cluster_id, try(data.terraform_remote_state.compute.outputs.exa2_vm_cluster_id, null))
  exa2_vm_cluster_name = coalesce(var.exa2_vm_cluster_name, try(data.terraform_remote_state.compute.outputs.exa2_vm_cluster_name, null))
  exa2_vm_cluster_ocid = coalesce(var.exa2_vm_cluster_ocid, try(data.terraform_remote_state.compute.outputs.exa2_vm_cluster_ocid, null))

  # exa3
  exa3_exainfra_id     = coalesce(var.exa3_exainfra_id, try(data.terraform_remote_state.compute.outputs.exa3_exainfra_id, null))
  exa3_exainfra_ocid   = coalesce(var.exa3_exainfra_ocid, try(data.terraform_remote_state.compute.outputs.exa3_exainfra_ocid, null))
  exa3_vm_cluster_id   = coalesce(var.exa3_vm_cluster_id, try(data.terraform_remote_state.compute.outputs.exa3_vm_cluster_id, null))
  exa3_vm_cluster_name = coalesce(var.exa3_vm_cluster_name, try(data.terraform_remote_state.compute.outputs.exa3_vm_cluster_name, null))
  exa3_vm_cluster_ocid = coalesce(var.exa3_vm_cluster_ocid, try(data.terraform_remote_state.compute.outputs.exa3_vm_cluster_ocid, null))
}

