# Set database home in newly created vm cluster
module "tst_db_home" {
  source = "../../../modules/oci-db-dbhome"

  vm_cluster_ocid = local.vm_cluster_ocid
  #db_system_ocid = local.vm_cluster_ocid
  db_home_source             = "NONE"
  db_home_name               = var.db_home_name
  db_home_version            = "19.23.0.0"
  is_desupported_version     = true
  database_software_image_id = "ocid1.databasesoftwareimage.oc1.iad.exampleuniqueiddataba0001"
}

/* Commented out per no ansible init
module "tst_cdb" {
  source  = "../../../modules/cdb"

  depends_on = [module.tst_db_home]

  db_home_ocid  = module.tst_db_home.oci_resource_ocid
  compartment_ocid = module.tst_db_home.oci_resource.compartment_id
  cdb_name           = "tstcdb"
  cdb_admin_password = var.cdb_admin_password
  cdb_source         = var.cdb_source
  cdb_auto_backup_enabled       = var.cdb_auto_backup_enabled
  environment = var.environment
  exainfra_id = local.exainfra_id
  exainfra_ocid = local.exainfra_ocid
  vm_cluster_id = local.vm_cluster_id
  vm_cluster_name = local.vm_cluster_name
  vm_cluster_ocid = local.vm_cluster_ocid
  destinations = [ var.notification_topic_ocid ]

}

module "tst_pdb" {
  depends_on = [module.tst_cdb]
  source  = "../../../modules/oci-db-pdb"

  environment = var.environment
  container_database_ocid = module.tst_cdb.cdb_resource_id
  compartment_ocid = module.tst_cdb.cdb_resource.compartment_id
  pdb_name                = var.pdb_name
  pdb_admin_password      = var.pdb_admin_password
  pdb_tde_wallet_password = var.pdb_tde_wallet_password
  exainfra_id = local.exainfra_id
  exainfra_ocid = local.exainfra_ocid
  vm_cluster_id = local.vm_cluster_id
  vm_cluster_name = local.vm_cluster_name
  vm_cluster_ocid = local.vm_cluster_ocid
  destinations = [ var.notification_topic_ocid ]
}
*/

module "apphome1_db_home" {
  source = "../../../modules/oci-db-dbhome"

  #environment     = var.environment
  vm_cluster_ocid = local.vm_cluster_ocid
  db_home_source  = "NONE"
  db_home_name    = "dbhome-Apphome1"
  db_home_version = var.db_home_version
}
/* apphome1_tst_cdb and apphome1_tst_pdb — commented out pending IAM policy verification
module "apphome1_tst_cdb" {
  source  = "../../../modules/cdb"

  depends_on = [module.apphome1_db_home]

  environment             = var.environment
  database_role           = "template"
  db_home_ocid            = module.apphome1_db_home.oci_resource_ocid
  compartment_ocid        = module.apphome1_db_home.oci_resource.compartment_id
  cdb_name                = "cdb064"
  cdb_admin_password      = var.cdb_admin_password
  cdb_source              = var.cdb_source
  cdb_auto_backup_enabled = var.cdb_auto_backup_enabled
  exainfra_id             = local.exainfra_id
  exainfra_ocid           = local.exainfra_ocid
  vm_cluster_id           = local.vm_cluster_id
  vm_cluster_name         = local.vm_cluster_name
  vm_cluster_ocid         = local.vm_cluster_ocid
}

module "apphome1_tst_pdb" {
  source  = "../../../modules/pdb"

  depends_on = [module.apphome1_tst_cdb]

  environment             = var.environment
  database_role           = "template"
  container_database_ocid = module.apphome1_tst_cdb.cdb_resource_id
  compartment_ocid        = module.apphome1_tst_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB062"
  pdb_admin_password      = var.pdb_admin_password
  pdb_tde_wallet_password = var.pdb_tde_wallet_password
  exainfra_id             = local.exainfra_id
  exainfra_ocid           = local.exainfra_ocid
  vm_cluster_id           = local.vm_cluster_id
  vm_cluster_name         = local.vm_cluster_name
  vm_cluster_ocid         = local.vm_cluster_ocid
}
*/

/* Commented out — cdb068 database no longer exists in OCI
module "cdb068_cdb" {
  source  = "../../../modules/cdb"

  depends_on              = [module.apphome1_db_home]
  environment             = var.environment
  database_role           = "regular"
  db_home_ocid            = module.apphome1_db_home.oci_resource_ocid
  compartment_ocid        = module.apphome1_db_home.oci_resource.compartment_id
  cdb_name                = "cdb068"
  cdb_admin_password      = null
  cdb_source              = var.cdb_source
  cdb_auto_backup_enabled = var.cdb_auto_backup_enabled

  exainfra_id     = local.exainfra_id
  exainfra_ocid   = local.exainfra_ocid
  vm_cluster_id   = local.vm_cluster_id
  vm_cluster_name = local.vm_cluster_name
  vm_cluster_ocid = local.vm_cluster_ocid

}

module "PDB026_pdb" {
  depends_on = [module.cdb068_cdb]
  source     = "../../../modules/pdb"

  environment             = var.environment
  database_role           = "regular"
  container_database_ocid = module.cdb068_cdb.cdb_resource_id
  compartment_ocid        = module.cdb068_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB026"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null

  exainfra_id     = local.exainfra_id
  exainfra_ocid   = local.exainfra_ocid
  vm_cluster_id   = local.vm_cluster_id
  vm_cluster_name = local.vm_cluster_name
  vm_cluster_ocid = local.vm_cluster_ocid
}
*/

/* Commented out 2026-11-13 — the TST cdb062/PDB060 no longer exist in OCI.
   State held ocid1.database.oc1.iad.exampleuniqueiddataba0002
   (CDB) and ocid1.pluggabledatabase.oc1.iad.exampleuniqueidplugga0001
   (PDB); both return 404 NotAuthorizedOrNotFound. The only live "cdb062" is
   cdb062_exa1vmc1 on the SBX cluster, which must NOT be adopted here.
   The removed blocks below forget them from state without destroying anything.
module "cdb062_cdb" {
  source  = "../../../modules/cdb"

  depends_on              = [module.apphome1_db_home]
  environment             = var.environment
  database_role           = "regular"
  db_home_ocid            = module.apphome1_db_home.oci_resource_ocid
  compartment_ocid        = module.apphome1_db_home.oci_resource.compartment_id
  cdb_name                = "cdb062"
  cdb_admin_password      = null
  cdb_source              = var.cdb_source
  cdb_auto_backup_enabled = true
  auto_backup_window      = "SLOT_SEVEN"
  auto_full_backup_day    = "SUNDAY"
  auto_full_backup_window = "SLOT_SEVEN"
  exainfra_id             = local.exainfra_id
  exainfra_ocid           = local.exainfra_ocid
  vm_cluster_id           = local.vm_cluster_id
  vm_cluster_name         = local.vm_cluster_name
  vm_cluster_ocid         = local.vm_cluster_ocid
}

module "PDB060_pdb" {
  depends_on = [module.cdb062_cdb]
  source     = "../../../modules/pdb"

  environment             = var.environment
  database_role           = "regular"
  container_database_ocid = module.cdb062_cdb.cdb_resource_id
  compartment_ocid        = module.cdb062_cdb.cdb_resource.compartment_id
  pdb_name                = "PDB060"
  pdb_admin_password      = null
  pdb_tde_wallet_password = null

  exainfra_id     = local.exainfra_id
  exainfra_ocid   = local.exainfra_ocid
  vm_cluster_id   = local.vm_cluster_id
  vm_cluster_name = local.vm_cluster_name
  vm_cluster_ocid = local.vm_cluster_ocid
}
*/

removed {
  from = module.cdb062_cdb
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.PDB060_pdb
  lifecycle {
    destroy = false
  }
}

# cdb067 (CDB) + PDB064 (PDB): created outside Terraform in dbhome-Apphome1
# (/u02/app/oracle/product/19.0.0.0/dbhome_1) and adopted via imports.tf.
# Backup settings mirror the live database (the module ignores the database
# block after import, so these do not change it).
# DB Management is OFF until dbsnmp on cdb067 accepts the shared DB Management
# secret (enabling it on 2026-11-13 failed: "username or password ... incorrect").
# Set enable_db_management = true on both modules once that is fixed.

# =========================================================================
# TST-cluster databases created outside Terraform, adopted 2026-11-13.
# OCIDs and DB homes verified from OCI (all AVAILABLE on exa1vmc1).
# State-only adoption: DB Management OFF; role regular (TST convention).
# =========================================================================

module "apphome2_db_home" {
  source = "../../../modules/oci-db-dbhome"

  vm_cluster_ocid = local.vm_cluster_ocid
  db_home_source  = "NONE"
  db_home_name    = "dbhome-apphome2"
  db_home_version = var.db_home_version
}

module "rr-datapump_db_home" {
  source = "../../../modules/oci-db-dbhome"

  vm_cluster_ocid = local.vm_cluster_ocid
  db_home_source  = "NONE"
  db_home_name    = "dbhome-rr-datapump"
  db_home_version = var.db_home_version
}

# =========================================================================
# Previously unmanaged databases — importing into Terraform.
# DB home OCIDs are hardcoded since these homes were created outside Terraform.
# =========================================================================

