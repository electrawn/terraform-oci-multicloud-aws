# ---------------------------------------------------------------------------
# 3_databases stage � orchestrates exa1, exa2, exa3 database modules.
# Cluster IDs are sourced from 2_compute remote state via locals.tf.
# ---------------------------------------------------------------------------
module "databases_exa1" {
  source                 = "./exa1"
  exainfra_id            = local.exa1_exainfra_id
  exainfra_ocid          = local.exa1_exainfra_ocid
  vm_cluster_id          = local.exa1_vm_cluster_id
  vm_cluster_name        = local.exa1_vm_cluster_name
  vm_cluster_ocid        = local.exa1_vm_cluster_ocid
  environment            = var.environment
  private_end_point_ocid = var.private_end_point_ocid
  # Legacy vars kept for variable interface compatibility
  db_home_name            = "dbhome-apphome1"
  db_home_version         = var.db_home_version
  cdb_name                = var.cdb_name
  cdb_admin_password      = var.cdb_admin_password
  cdb_source              = var.cdb_source
  pdb_name                = var.pdb_name
  pdb_admin_password      = var.pdb_admin_password
  pdb_tde_wallet_password = var.pdb_tde_wallet_password
}
module "databases_exa2" {
  source                  = "./exa2"
  exainfra_id             = local.exa2_exainfra_id
  exainfra_ocid           = local.exa2_exainfra_ocid
  vm_cluster_id           = local.exa2_vm_cluster_id
  vm_cluster_name         = local.exa2_vm_cluster_name
  vm_cluster_ocid         = local.exa2_vm_cluster_ocid
  environment             = var.environment
  private_end_point_ocid  = var.private_end_point_ocid
  db_home_name            = "dbhome-Apphome1"
  db_home_version         = var.db_home_version
  cdb_name                = var.cdb_name
  cdb_admin_password      = var.cdb_admin_password
  cdb_source              = var.cdb_source
  pdb_name                = var.pdb_name
  pdb_admin_password      = var.pdb_admin_password
  pdb_tde_wallet_password = var.pdb_tde_wallet_password
}
module "databases_exa3" {
  source                  = "./exa3"
  exainfra_id             = local.exa3_exainfra_id
  exainfra_ocid           = local.exa3_exainfra_ocid
  vm_cluster_id           = local.exa3_vm_cluster_id
  vm_cluster_name         = local.exa3_vm_cluster_name
  vm_cluster_ocid         = local.exa3_vm_cluster_ocid
  environment             = var.environment
  private_end_point_ocid  = var.private_end_point_ocid
  db_home_name            = "dbhome-20260306204s"
  db_home_version         = var.db_home_version
  cdb_name                = var.cdb_name
  cdb_admin_password      = var.cdb_admin_password
  cdb_source              = var.cdb_source
  pdb_name                = var.pdb_name
  pdb_admin_password      = var.pdb_admin_password
  pdb_tde_wallet_password = var.pdb_tde_wallet_password
}

# ========================================
# Root outputs forwarded from submodules
# ========================================
output "databases_exa1" {
  value = module.databases_exa1
}

output "databases_exa2" {
  value = module.databases_exa2
}

output "databases_exa3" {
  value = module.databases_exa3
}

# Merged CDB/PDB maps for 4_monitoring consumption
output "cdbs" {
  description = "Merged map of all CDBs across all clusters"
  value       = merge(module.databases_exa1.cdbs, module.databases_exa2.cdbs, module.databases_exa3.cdbs)
  sensitive   = false
}

output "pdbs" {
  description = "Merged map of all PDBs across all clusters"
  value       = merge(module.databases_exa1.pdbs, module.databases_exa2.pdbs, module.databases_exa3.pdbs)
  sensitive   = false
}
