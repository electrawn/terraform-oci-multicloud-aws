# Set database home in newly created vm cluster
module "dbhome_example_db_home" {
  source          = "../../../../modules/oci-db-dbhome"
  vm_cluster_ocid = var.vm_cluster_ocid
  db_home_source  = "NONE"
  db_home_name    = "dbhome-example"
  db_home_version = "19.23.0.0.0"
}

# These databases are regularly dropped and recreated so monitoring is not needed.

# These databases are regularly dropped and recreated so monitoring is not needed.

# Generated from example-state terraform.tfstate:
# oci_database_pluggable_database records mapped by container_database_id to exa3 CDB modules.

/*
module "cdb074_cdb" {
  source  = "../../../../modules/cdb"
  depends_on              = [module.dbhome_example_db_home]
  environment             = var.environment
  db_home_ocid            = module.dbhome_example_db_home.oci_resource_ocid
  compartment_ocid        = module.dbhome_example_db_home.oci_resource.compartment_id
  cdb_name                = "cdb074"
  cdb_admin_password      = null
  cdb_source              = var.cdb_source
  cdb_auto_backup_enabled = true
  exainfra_id             = var.exainfra_id
  exainfra_ocid           = var.exainfra_ocid
  vm_cluster_id           = var.vm_cluster_id
  vm_cluster_name         = var.vm_cluster_name
  vm_cluster_ocid         = var.vm_cluster_ocid
  private_end_point_ocid  = var.private_end_point_ocid
  enable_db_management    = true
}
*/

/*
module "cdb009_PDB010_pdb" {
  depends_on = [module.cdb009_cdb]
  source     = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb009_cdb.cdb_resource_id
  compartment_ocid        = module.cdb009_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB010"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null

  exainfra_id            = var.exainfra_id
  exainfra_ocid          = var.exainfra_ocid
  vm_cluster_id          = var.vm_cluster_id
  vm_cluster_name        = var.vm_cluster_name
  vm_cluster_ocid        = var.vm_cluster_ocid
  private_end_point_ocid = var.private_end_point_ocid
}

module "cdb010_PDB011_pdb" {
  depends_on = [module.cdb010_cdb]
  source     = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb010_cdb.cdb_resource_id
  compartment_ocid        = module.cdb010_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB011"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null

  exainfra_id            = var.exainfra_id
  exainfra_ocid          = var.exainfra_ocid
  vm_cluster_id          = var.vm_cluster_id
  vm_cluster_name        = var.vm_cluster_name
  vm_cluster_ocid        = var.vm_cluster_ocid
  private_end_point_ocid = var.private_end_point_ocid
}

module "cdb021_PDB020_pdb" {
  depends_on = [module.cdb021_cdb]
  source     = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb021_cdb.cdb_resource_id
  compartment_ocid        = module.cdb021_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB020"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null

  exainfra_id            = var.exainfra_id
  exainfra_ocid          = var.exainfra_ocid
  vm_cluster_id          = var.vm_cluster_id
  vm_cluster_name        = var.vm_cluster_name
  vm_cluster_ocid        = var.vm_cluster_ocid
  private_end_point_ocid = var.private_end_point_ocid
}

module "cdb022_PDB021_pdb" {
  depends_on = [module.cdb022_cdb]
  source     = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb022_cdb.cdb_resource_id
  compartment_ocid        = module.cdb022_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB021"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null

  exainfra_id            = var.exainfra_id
  exainfra_ocid          = var.exainfra_ocid
  vm_cluster_id          = var.vm_cluster_id
  vm_cluster_name        = var.vm_cluster_name
  vm_cluster_ocid        = var.vm_cluster_ocid
  private_end_point_ocid = var.private_end_point_ocid
}

module "cdb037_PDB033_pdb" {
  depends_on = [module.cdb037_cdb]
  source     = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb037_cdb.cdb_resource_id
  compartment_ocid        = module.cdb037_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB033"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null

  exainfra_id            = var.exainfra_id
  exainfra_ocid          = var.exainfra_ocid
  vm_cluster_id          = var.vm_cluster_id
  vm_cluster_name        = var.vm_cluster_name
  vm_cluster_ocid        = var.vm_cluster_ocid
  private_end_point_ocid = var.private_end_point_ocid
}

module "cdb038_PDB034_pdb" {
  depends_on = [module.cdb038_cdb]
  source     = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb038_cdb.cdb_resource_id
  compartment_ocid        = module.cdb038_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB034"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null

  exainfra_id            = var.exainfra_id
  exainfra_ocid          = var.exainfra_ocid
  vm_cluster_id          = var.vm_cluster_id
  vm_cluster_name        = var.vm_cluster_name
  vm_cluster_ocid        = var.vm_cluster_ocid
  private_end_point_ocid = var.private_end_point_ocid
}

module "cdb040_PDB036_pdb" {
  depends_on = [module.cdb040_cdb]
  source     = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb040_cdb.cdb_resource_id
  compartment_ocid        = module.cdb040_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB036"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null

  exainfra_id            = var.exainfra_id
  exainfra_ocid          = var.exainfra_ocid
  vm_cluster_id          = var.vm_cluster_id
  vm_cluster_name        = var.vm_cluster_name
  vm_cluster_ocid        = var.vm_cluster_ocid
  private_end_point_ocid = var.private_end_point_ocid
}

module "cdb041_PDB037_pdb" {
  depends_on = [module.cdb041_cdb]
  source     = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb041_cdb.cdb_resource_id
  compartment_ocid        = module.cdb041_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB037"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null

  exainfra_id            = var.exainfra_id
  exainfra_ocid          = var.exainfra_ocid
  vm_cluster_id          = var.vm_cluster_id
  vm_cluster_name        = var.vm_cluster_name
  vm_cluster_ocid        = var.vm_cluster_ocid
  private_end_point_ocid = var.private_end_point_ocid
}

module "cdb047_PDB045_pdb" {
  depends_on = [module.cdb047_cdb]
  source     = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb047_cdb.cdb_resource_id
  compartment_ocid        = module.cdb047_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB045"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null

  exainfra_id            = var.exainfra_id
  exainfra_ocid          = var.exainfra_ocid
  vm_cluster_id          = var.vm_cluster_id
  vm_cluster_name        = var.vm_cluster_name
  vm_cluster_ocid        = var.vm_cluster_ocid
  private_end_point_ocid = var.private_end_point_ocid
}

module "cdb048_PDB044_pdb" {
  depends_on = [module.cdb048_cdb]
  source     = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb048_cdb.cdb_resource_id
  compartment_ocid        = module.cdb048_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB044"
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

/*
module "cdb009_PDB013_pdb" {
  depends_on = [module.cdb009_cdb]
  source     = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb009_cdb.cdb_resource_id
  compartment_ocid        = module.cdb009_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB013"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null
  exainfra_id             = var.exainfra_id
  exainfra_ocid           = var.exainfra_ocid
  vm_cluster_id           = var.vm_cluster_id
  vm_cluster_name         = var.vm_cluster_name
  vm_cluster_ocid         = var.vm_cluster_ocid
  private_end_point_ocid  = var.private_end_point_ocid
  enable_db_management    = true
}
*/

# NOTE: OCI reality — the PDB restored under CDB cdb040 is named PDB040
# (not PDB517). Block + pdb_name aligned to OCI; state moved via `state mv`
# so the existing resource is preserved (no destroy). Same PDB name also
# exists on cdb042 (different OCID) — that is expected.

/*
module "cdb074_PDB069_pdb" {
  depends_on              = [module.cdb074_cdb]
  source  = "../../../../modules/pdb"
  environment             = var.environment
  container_database_ocid = module.cdb074_cdb.cdb_resource_id
  compartment_ocid        = module.cdb074_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB069"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null
  exainfra_id             = var.exainfra_id
  exainfra_ocid           = var.exainfra_ocid
  vm_cluster_id           = var.vm_cluster_id
  vm_cluster_name         = var.vm_cluster_name
  vm_cluster_ocid         = var.vm_cluster_ocid
  private_end_point_ocid  = var.private_end_point_ocid
}
*/

/*
# Commented: All database and CDB/PDB modules below disabled during initial exa3 setup
# These can be re-enabled after db_home is established and validated

# module "tst_cdb" {
#   ...existing code...
# }
#
# module "tst_pdb" {
#   ...existing code...
# }
*/

# ...existing code commented... (apphome1_db_home and related CDB/PDB modules disabled)

/*
# All CDB/PDB database modules disabled during exa3 initial setup
# These modules were copied from exa1 and require validation before enabling
# Future work: Customize per database requirements and enable as needed
#
# Disabled modules:
# - cdb057_cdb + PDB510_pdb
# - cdb068_cdb + PDB026_pdb + cdb027_cdb + PDB026_pdb_1
# - cdb015_cdb + PDB505_pdb
# - cdb060_cdb + PDB512_pdb (commented)
# - cdb069_cdb + PDB513_pdb
# - cdb062_cdb + PDB060_pdb
# - cdb017_cdb + PDB506_pdb
# - cdb031_cdb + PDB511_pdb
# - cdb051_cdb + PDB507_pdb
# - cdb005_cdb + PDB501_pdb
# - apphome2_db_home + cdb055_cdb + PDB055_pdb + cdb056_cdb + PDB056_pdb
# - rr-datapump_db_home + cdb071_cdb + PDB066_pdb
*/

