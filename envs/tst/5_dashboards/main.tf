# -------------------------------------------
# CloudWatch Dashboards for Dev VM Cluster
# -------------------------------------------

# Cluster-level dashboard (VM Cluster metrics)
module "cluster_dashboard" {
  source = "../../../modules/cloudwatch/cluster_dashboards"

  exainfra_id   = local.exainfra_id
  vm_cluster_id = local.vm_cluster_id
  environment   = var.environment
}

# Global CDB dashboard (all CDBs on the VM cluster)
module "cdb_dashboard" {
  source = "../../../modules/cloudwatch/cdb_dashboards"

  exainfra_id     = local.exainfra_id
  exainfra_ocid   = local.exainfra_ocid
  vm_cluster_id   = local.vm_cluster_id
  vm_cluster_name = local.vm_cluster_name
  vm_cluster_ocid = local.vm_cluster_ocid
  environment     = var.environment

  # From 3_databases state (single source); static list only if state is unavailable.
  databases = length(local.cdb_ocids) > 0 ? sort(keys(local.cdb_ocids)) : var.cdb_databases
}

# Global PDB dashboard (all PDBs on the VM cluster)
module "pdb_dashboard" {
  source = "../../../modules/cloudwatch/pdb_dashboards"

  exainfra_id     = local.exainfra_id
  exainfra_ocid   = local.exainfra_ocid
  vm_cluster_id   = local.vm_cluster_id
  vm_cluster_name = local.vm_cluster_name
  vm_cluster_ocid = local.vm_cluster_ocid
  environment     = var.environment

  databases = length(local.pdb_ocids) > 0 ? sort(keys(local.pdb_ocids)) : var.pdb_databases
}

# Individual per-CDB dashboards (one dashboard per CDB database)
module "cdb_dashboard_individual" {
  source = "../../../modules/cloudwatch/cdb_dashboards_individual"

  exainfra_id     = local.exainfra_id
  exainfra_ocid   = local.exainfra_ocid
  vm_cluster_id   = local.vm_cluster_id
  vm_cluster_name = local.vm_cluster_name
  vm_cluster_ocid = local.vm_cluster_ocid
  environment     = var.environment
  region          = var.aws_region

  # Real DB names from 3_databases remote state, so the Metrics Insights
  # resourceName filter matches the published metric dimensions. Falls back to
  # the static list only if the remote-state map is unavailable.
  databases = length(local.cdb_ocids) > 0 ? sort(keys(local.cdb_ocids)) : var.cdb_databases
}

# Individual per-PDB dashboards (one dashboard per PDB database)
module "pdb_dashboard_individual" {
  source = "../../../modules/cloudwatch/pdb_dashboards_individual"

  exainfra_id     = local.exainfra_id
  exainfra_ocid   = local.exainfra_ocid
  vm_cluster_id   = local.vm_cluster_id
  vm_cluster_name = local.vm_cluster_name
  vm_cluster_ocid = local.vm_cluster_ocid
  environment     = var.environment
  region          = var.aws_region

  databases = length(local.pdb_ocids) > 0 ? sort(keys(local.pdb_ocids)) : var.pdb_databases
}

# -------------------------------------------
# OCI-side dashboards (Management Dashboard service)
# -------------------------------------------

# OCI-side per-CDB management dashboards (oracle_oci_database namespace).
module "oci_cdb_dashboard" {
  source = "../../../modules/ocimon/cdb_dashboards"

  compartment_ocid = local.monitor_compartment_ocid
  vm_cluster_name  = local.vm_cluster_name
  environment      = var.environment
  region           = var.oci_region

  databases = local.cdb_ocids
}

# OCI-side per-PDB management dashboards (oracle_oci_database namespace).
module "oci_pdb_dashboard" {
  source = "../../../modules/ocimon/pdb_dashboards"

  compartment_ocid = local.monitor_compartment_ocid
  vm_cluster_name  = local.vm_cluster_name
  environment      = var.environment
  region           = var.oci_region

  databases = local.pdb_ocids

  # Run after the CDB import: concurrent dashboard imports into the same
  # compartment fail with DashxApis 500 InternalError (each succeeds alone).
  depends_on = [module.oci_cdb_dashboard]
}

# ZDLAR (Zero Data Loss Autonomous Recovery Service) dashboards.
# One OCI Management Dashboard per protected database. Populate
# var.zdlar_protected_databases as CDBs onboard to the ZDLAR service.
module "zdlar_dashboard" {
  source = "../../../modules/ocimon/zdlar_dashboards"

  compartment_ocid = local.monitor_compartment_ocid
  vm_cluster_name  = local.vm_cluster_name
  environment      = var.environment
  region           = var.oci_region

  protected_databases = var.zdlar_protected_databases
}
