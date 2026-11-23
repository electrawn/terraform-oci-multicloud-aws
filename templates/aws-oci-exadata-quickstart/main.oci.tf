locals {
  # Use the oci_region from variable if provided, otherwise get it from the autonomous_vm_cluster module
  oci_region  = coalesce(var.oci_region, module.exadata_vm_cluster.oci_region)
  environment = lookup(var.tags, "Environment", "prd")

  # IDs of depending resources
  compartment_ocid = module.exadata_vm_cluster.oci_compartment_ocid
}

# Set database home in newly created vm cluster
module "db_home" {
  source     = "../../modules/oci-db-dbhome"
  depends_on = [module.exadata_vm_cluster]

  vm_cluster_ocid = module.exadata_vm_cluster.oci_resource_ocid
  db_home_source  = var.db_home_source
  db_home_name    = var.db_home_name
  db_home_version = var.db_home_version
}

module "cdb" {
  source     = "../../modules/cdb"
  depends_on = [module.db_home]

  db_home_ocid            = module.db_home.oci_resource_ocid
  compartment_ocid        = local.compartment_ocid
  cdb_name                = var.cdb_name
  cdb_admin_password      = var.cdb_admin_password
  cdb_source              = var.cdb_source
  cdb_auto_backup_enabled = var.cdb_auto_backup_enabled

  exainfra_id     = module.exadata_infrastructure.resource_id
  exainfra_ocid   = module.exadata_infrastructure.oci_resource_ocid
  vm_cluster_id   = module.exadata_vm_cluster.resource_id
  vm_cluster_name = module.exadata_vm_cluster.resource.cluster_name
  vm_cluster_ocid = module.exadata_vm_cluster.oci_resource_ocid
  environment     = local.environment
  tags            = var.tags
  alarms_enabled  = true
}

module "pdb" {
  depends_on = [module.cdb]
  source     = "../../modules/pdb"

  container_database_ocid = module.cdb.cdb_resource_id
  compartment_ocid        = module.cdb.cdb_resource.compartment_id
  pdb_name                = var.pdb_name
  pdb_admin_password      = var.pdb_admin_password
  pdb_tde_wallet_password = var.pdb_tde_wallet_password

  exainfra_id     = module.exadata_infrastructure.resource_id
  exainfra_ocid   = module.exadata_infrastructure.oci_resource_ocid
  vm_cluster_id   = module.exadata_vm_cluster.resource_id
  vm_cluster_name = module.exadata_vm_cluster.resource.cluster_name
  vm_cluster_ocid = module.exadata_vm_cluster.oci_resource_ocid
  environment     = local.environment
  tags            = var.tags
  alarms_enabled  = true
}
