# ==========================================================================
# PRODUCTION DATABASES - exa1 cluster (exa1vmc1)
# Generated from example-state terraform.tfstate
# ==========================================================================

module "dbhome_apphome1_db_home" {
  source          = "../../../../modules/oci-db-dbhome"
  vm_cluster_ocid = var.vm_cluster_ocid
  db_home_source  = "NONE"
  db_home_name    = "dbhome-apphome1"
  db_home_version = "19.23.0.0.0"
}

module "dbhome_apphome1_template_db_home" {
  source          = "../../../../modules/oci-db-dbhome"
  vm_cluster_ocid = var.vm_cluster_ocid
  db_home_source  = "NONE"
  db_home_name    = "dbhome-apphome1-Template"
  db_home_version = "19.23.0.0.0"
}

# ==========================================================================
# Imported from OCI (drift reconciliation) - exa1 exa1vmc1
# cdb007 CDB + PDB009 PDB, and PDB042 PDB under existing cdb044_cdb
# ==========================================================================

