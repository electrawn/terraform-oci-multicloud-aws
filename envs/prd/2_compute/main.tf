# ---------------------------------------------------------------------------
# 2_compute stage — orchestrates exa1, exa2, exa3 Exadata clusters
# ODB network ID is sourced from 1_network remote state.
# ---------------------------------------------------------------------------

locals {
  vmc_odb_network_id = data.terraform_remote_state.network.outputs.aws_odb_network_resource_id
}

module "compute_exa1" {
  source                                 = "./exa1"
  exadata_infrastructure_name            = var.exa1_exadata_infrastructure_name
  exadata_infrastructure_compute_count   = var.exa1_exadata_infrastructure_compute_count
  exadata_infrastructure_storage_count   = var.exa1_exadata_infrastructure_storage_count
  vmc_vm_cluster_name                    = var.exa1_vmc_vm_cluster_name
  vmc_gi_cluster_name                    = var.exa1_vmc_gi_cluster_name
  vmc_cpu_core_count_per_vm              = var.exa1_vmc_cpu_core_count_per_vm
  vmc_gi_version                         = "23.0.0.0"
  vmc_hostname_prefix                    = var.exa1_vmc_hostname_prefix
  vmc_vm_ssh_public_keys                 = var.exa1_vmc_vm_ssh_public_keys
  vmc_odb_network_id                     = local.vmc_odb_network_id
  vmc_license_model                      = "LICENSE_INCLUDED"
  vmc_data_storage_size_in_tbs           = var.exa1_vmc_data_storage_size_in_tbs
  vmc_db_node_storage_size_in_gbs_per_vm = var.exa1_vmc_db_node_storage_size_in_gbs_per_vm
  vmc_memory_size_in_gbs_per_vm          = var.exa1_vmc_memory_size_in_gbs_per_vm
  environment                            = var.environment
  opsgenie_alert_arn                     = var.opsgenie_alert_arn
  enable_inline_monitoring               = var.enable_inline_monitoring
}

module "compute_exa2" {
  source                                 = "./exa2"
  exadata_infrastructure_name            = var.exa2_exadata_infrastructure_name
  exadata_infrastructure_compute_count   = var.exa2_exadata_infrastructure_compute_count
  exadata_infrastructure_storage_count   = var.exa2_exadata_infrastructure_storage_count
  vmc_vm_cluster_name                    = var.exa2_vmc_vm_cluster_name
  vmc_gi_cluster_name                    = var.exa2_vmc_gi_cluster_name
  vmc_cpu_core_count_per_vm              = var.exa2_vmc_cpu_core_count_per_vm
  vmc_gi_version                         = "23.0.0.0"
  vmc_hostname_prefix                    = var.exa2_vmc_hostname_prefix
  vmc_vm_ssh_public_keys                 = var.exa2_vmc_vm_ssh_public_keys
  vmc_odb_network_id                     = local.vmc_odb_network_id
  vmc_license_model                      = "LICENSE_INCLUDED"
  vmc_data_storage_size_in_tbs           = var.exa2_vmc_data_storage_size_in_tbs
  vmc_db_node_storage_size_in_gbs_per_vm = var.exa2_vmc_db_node_storage_size_in_gbs_per_vm
  vmc_memory_size_in_gbs_per_vm          = var.exa2_vmc_memory_size_in_gbs_per_vm
  environment                            = var.environment
  opsgenie_alert_arn                     = var.opsgenie_alert_arn
  enable_inline_monitoring               = var.enable_inline_monitoring
}

module "compute_exa3" {
  source                                 = "./exa3"
  exadata_infrastructure_name            = var.exa3_exadata_infrastructure_name
  exadata_infrastructure_compute_count   = var.exa3_exadata_infrastructure_compute_count
  exadata_infrastructure_storage_count   = var.exa3_exadata_infrastructure_storage_count
  vmc_vm_cluster_name                    = var.exa3_vmc_vm_cluster_name
  vmc_gi_cluster_name                    = var.exa3_vmc_gi_cluster_name
  vmc_cpu_core_count_per_vm              = var.exa3_vmc_cpu_core_count_per_vm
  vmc_gi_version                         = "23.0.0.0"
  vmc_hostname_prefix                    = var.exa3_vmc_hostname_prefix
  vmc_vm_ssh_public_keys                 = var.exa3_vmc_vm_ssh_public_keys
  vmc_odb_network_id                     = local.vmc_odb_network_id
  vmc_license_model                      = "LICENSE_INCLUDED"
  vmc_data_storage_size_in_tbs           = var.exa3_vmc_data_storage_size_in_tbs
  vmc_db_node_storage_size_in_gbs_per_vm = var.exa3_vmc_db_node_storage_size_in_gbs_per_vm
  vmc_memory_size_in_gbs_per_vm          = var.exa3_vmc_memory_size_in_gbs_per_vm
  environment                            = var.environment
  opsgenie_alert_arn                     = var.opsgenie_alert_arn
  enable_inline_monitoring               = var.enable_inline_monitoring
  is_enabled_vm_cluster_cpu              = var.compute_exa3_is_enabled_vm_cluster_cpu
}

