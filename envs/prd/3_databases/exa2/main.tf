# ==========================================================================
# PRODUCTION DATABASES - exa2 cluster (exa2vmc1)
# Generated from example-state terraform.tfstate
# DB Homes: dbhome-Apphome1 (19 CDB/PDB pairs + 4 CDB-only), dbhome-Apphome1-datapump-patch (1 CDB/PDB pair)
# CDB-only modules included: none
# ==========================================================================

# DB Home: dbhome-Apphome1
module "dbhome_apphome1_db_home" {
  source          = "../../../../modules/oci-db-dbhome"
  vm_cluster_ocid = var.vm_cluster_ocid
  db_home_source  = "NONE"
  db_home_name    = "dbhome-Apphome1"
  db_home_version = "19.23.0.0.0"
}

# DB Home: dbhome-Apphome1-datapump-patch
module "dbhome_apphome1_datapump_patch_db_home" {
  source          = "../../../../modules/oci-db-dbhome"
  vm_cluster_ocid = var.vm_cluster_ocid
  db_home_source  = "NONE"
  db_home_name    = "dbhome-Apphome1-datapump-patch"
  db_home_version = "19.23.0.0.0"
}

/*
module "cdb070_cdb" {
  source  = "../../../../modules/cdb"
  depends_on              = [module.dbhome_apphome1_datapump_patch_db_home]
  environment             = var.environment
  db_home_ocid            = module.dbhome_apphome1_datapump_patch_db_home.oci_resource_ocid
  compartment_ocid        = module.dbhome_apphome1_datapump_patch_db_home.oci_resource.compartment_id
  cdb_name                = "cdb070"
  cdb_admin_password      = null
  cdb_source              = var.cdb_source
  cdb_auto_backup_enabled = true
  exainfra_id             = var.exainfra_id
  exainfra_ocid           = var.exainfra_ocid
  vm_cluster_id           = var.vm_cluster_id
  vm_cluster_name         = var.vm_cluster_name
  vm_cluster_ocid         = var.vm_cluster_ocid
  private_end_point_ocid  = var.private_end_point_ocid
}
*/

/*
module "cdb070_PDB065_pdb" {
  depends_on = [module.cdb070_cdb]
  source     = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb070_cdb.cdb_resource_id
  compartment_ocid        = module.cdb070_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB065"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null

  exainfra_id            = var.exainfra_id
  exainfra_ocid          = var.exainfra_ocid
  vm_cluster_id          = var.vm_cluster_id
  vm_cluster_name        = var.vm_cluster_name
  vm_cluster_ocid        = var.vm_cluster_ocid
  private_end_point_ocid = var.private_end_point_ocid
}
*/

# ==========================================================================
# Imported from OCI (drift reconciliation) - exa2 exa2vmc1
# cdb019 CDB (no PDBs) and PDB006 PDB under existing cdb003_cdb
# ==========================================================================


