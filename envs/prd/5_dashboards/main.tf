# -------------------------------------------
# CloudWatch Dashboards for Prd VM Cluster
# -------------------------------------------

# Cluster-level dashboard (VM Cluster + per-node metrics), one per cluster
# (exa1 / exa2 / exa3).
module "cluster_dashboard" {
  source = "../../../modules/cloudwatch/cluster_dashboards"

  for_each = local.clusters_resolved

  exainfra_id   = each.value.exainfra_id
  vm_cluster_id = each.value.vm_cluster_id
  environment   = var.environment
}

# Global CDB dashboard (all CDBs on the VM cluster), one per cluster.
module "cdb_dashboard" {
  source = "../../../modules/cloudwatch/cdb_dashboards"

  for_each = local.clusters_resolved

  exainfra_id     = each.value.exainfra_id
  exainfra_ocid   = each.value.exainfra_ocid
  vm_cluster_id   = each.value.vm_cluster_id
  vm_cluster_name = each.value.vm_cluster_name
  vm_cluster_ocid = each.value.vm_cluster_ocid
  environment     = var.environment

  databases = each.value.cdb_databases
}

# Global PDB dashboard (all PDBs on the VM cluster), one per cluster.
module "pdb_dashboard" {
  source = "../../../modules/cloudwatch/pdb_dashboards"

  for_each = local.clusters_resolved

  exainfra_id     = each.value.exainfra_id
  exainfra_ocid   = each.value.exainfra_ocid
  vm_cluster_id   = each.value.vm_cluster_id
  vm_cluster_name = each.value.vm_cluster_name
  vm_cluster_ocid = each.value.vm_cluster_ocid
  environment     = var.environment

  databases = each.value.pdb_databases
}


# Individual per-CDB dashboards (one dashboard per CDB database), for every
# cluster defined in var.clusters (exa1 / exa2 / exa3).
module "cdb_dashboard_individual" {
  source = "../../../modules/cloudwatch/cdb_dashboards_individual"

  for_each = local.clusters_resolved

  exainfra_id     = each.value.exainfra_id
  exainfra_ocid   = each.value.exainfra_ocid
  vm_cluster_id   = each.value.vm_cluster_id
  vm_cluster_name = each.value.vm_cluster_name
  vm_cluster_ocid = each.value.vm_cluster_ocid
  environment     = var.environment
  region          = var.aws_region

  # Real DB names from 3_databases remote state (per cluster) so the Metrics
  # Insights resourceName filter matches published metric dimensions. Falls
  # back to the static tfvars list if the remote-state map is empty.
  databases = each.value.cdb_databases
}

# Individual per-PDB dashboards (one dashboard per PDB database), for every
# cluster defined in var.clusters (exa1 / exa2 / exa3).
module "pdb_dashboard_individual" {
  source = "../../../modules/cloudwatch/pdb_dashboards_individual"

  for_each = local.clusters_resolved

  exainfra_id     = each.value.exainfra_id
  exainfra_ocid   = each.value.exainfra_ocid
  vm_cluster_id   = each.value.vm_cluster_id
  vm_cluster_name = each.value.vm_cluster_name
  vm_cluster_ocid = each.value.vm_cluster_ocid
  environment     = var.environment
  region          = var.aws_region

  databases = each.value.pdb_databases
}

# -------------------------------------------
# OCI-side dashboards (Management Dashboard service)
# -------------------------------------------

# OCI-side per-CDB / per-PDB management dashboards (oracle_oci_database namespace), one module per cluster so dashboard names carry the correct cluster and DB-name collisions across clusters are avoided.
# The six imports are CHAINED (cdb exa1 -> exa2 -> exa3 -> pdb exa1 -> exa2 -> exa3): concurrent
# dashboard imports into the same compartment fail with DashxApis 500 InternalError (each succeeds
# alone; same cause as dev 907ca27). AWS CloudWatch dashboards are created first so they are applied
# even if the OCI import fails mid-apply.

module "oci_cdb_dashboard_exa1" {
  source = "../../../modules/ocimon/cdb_dashboards"

  compartment_ocid = local.monitor_compartment_ocid
  vm_cluster_name  = local.oci_clusters["exa1"].vm_cluster_name
  environment      = var.environment
  region           = var.oci_region

  databases = local.oci_clusters["exa1"].cdb_ocids

  depends_on = [
    module.cluster_dashboard,
    module.cdb_dashboard,
    module.pdb_dashboard,
    module.cdb_dashboard_individual,
    module.pdb_dashboard_individual,
  ]
}

module "oci_cdb_dashboard_exa2" {
  source = "../../../modules/ocimon/cdb_dashboards"

  compartment_ocid = local.monitor_compartment_ocid
  vm_cluster_name  = local.oci_clusters["exa2"].vm_cluster_name
  environment      = var.environment
  region           = var.oci_region

  databases = local.oci_clusters["exa2"].cdb_ocids

  depends_on = [
    module.cluster_dashboard,
    module.cdb_dashboard,
    module.pdb_dashboard,
    module.cdb_dashboard_individual,
    module.pdb_dashboard_individual,
    module.oci_cdb_dashboard_exa1,
  ]
}

module "oci_cdb_dashboard_exa3" {
  source = "../../../modules/ocimon/cdb_dashboards"

  compartment_ocid = local.monitor_compartment_ocid
  vm_cluster_name  = local.oci_clusters["exa3"].vm_cluster_name
  environment      = var.environment
  region           = var.oci_region

  databases = local.oci_clusters["exa3"].cdb_ocids

  depends_on = [
    module.cluster_dashboard,
    module.cdb_dashboard,
    module.pdb_dashboard,
    module.cdb_dashboard_individual,
    module.pdb_dashboard_individual,
    module.oci_cdb_dashboard_exa2,
  ]
}

module "oci_pdb_dashboard_exa1" {
  source = "../../../modules/ocimon/pdb_dashboards"

  compartment_ocid = local.monitor_compartment_ocid
  vm_cluster_name  = local.oci_clusters["exa1"].vm_cluster_name
  environment      = var.environment
  region           = var.oci_region

  databases = local.oci_clusters["exa1"].pdb_ocids

  depends_on = [
    module.cluster_dashboard,
    module.cdb_dashboard,
    module.pdb_dashboard,
    module.cdb_dashboard_individual,
    module.pdb_dashboard_individual,
    module.oci_cdb_dashboard_exa3,
  ]
}

module "oci_pdb_dashboard_exa2" {
  source = "../../../modules/ocimon/pdb_dashboards"

  compartment_ocid = local.monitor_compartment_ocid
  vm_cluster_name  = local.oci_clusters["exa2"].vm_cluster_name
  environment      = var.environment
  region           = var.oci_region

  databases = local.oci_clusters["exa2"].pdb_ocids

  depends_on = [
    module.cluster_dashboard,
    module.cdb_dashboard,
    module.pdb_dashboard,
    module.cdb_dashboard_individual,
    module.pdb_dashboard_individual,
    module.oci_pdb_dashboard_exa1,
  ]
}

module "oci_pdb_dashboard_exa3" {
  source = "../../../modules/ocimon/pdb_dashboards"

  compartment_ocid = local.monitor_compartment_ocid
  vm_cluster_name  = local.oci_clusters["exa3"].vm_cluster_name
  environment      = var.environment
  region           = var.oci_region

  databases = local.oci_clusters["exa3"].pdb_ocids

  depends_on = [
    module.cluster_dashboard,
    module.cdb_dashboard,
    module.pdb_dashboard,
    module.cdb_dashboard_individual,
    module.pdb_dashboard_individual,
    module.oci_pdb_dashboard_exa2,
  ]
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

  # AWS CloudWatch dashboards first (see oci_cdb_dashboard note).
  depends_on = [
    module.cluster_dashboard,
    module.cdb_dashboard,
    module.pdb_dashboard,
    module.cdb_dashboard_individual,
    module.pdb_dashboard_individual,
  ]
}
