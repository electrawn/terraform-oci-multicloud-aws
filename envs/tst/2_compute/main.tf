# ------------------------
# AWS / OCI / Compute
# ------------------------

locals {
  # IDs of depending resources
  cloud_exadata_infrastructure_id = module.exadata_infrastructure.resource_id
  #odb_network_id  = module.odb_network.aws_odb_network_resource_id
  odb_network_id = var.vmc_odb_network_id
  #peer_network_id = var.odb_peering_connection_peer_network_id == null ? module.aws_ia_vpc[0].vpc_attributes.id : var.odb_peering_connection_peer_network_id
}

# -------------------------
# Exadata Infrastructures
# -------------------------

#Create exa data infrastructure
module "exadata_infrastructure" {
  source                                 = "../../../modules/aws-odb-exadata-infra"
  aws_odb_exa_infra_availability_zone_id = var.availability_zone_id
  exa_infra_display_name                 = var.exadata_infrastructure_name
  exa_infra_shape                        = var.exadata_infrastructure_shape
  compute_count                          = var.exadata_infrastructure_compute_count
  storage_count                          = var.exadata_infrastructure_storage_count
  tags                                   = merge(var.tags, { "Environment" : var.environment })
  maintenance_window                     = var.exadata_infrastructure_maintenance_window
  customer_contacts_to_send_to_oci       = var.exadata_infrastructure_customer_contacts
}

# Create  VM cluster in OCI
module "exadata_vm_cluster" {
  depends_on = [module.exadata_infrastructure]
  source     = "../../../modules/aws-odb-vmc"

  aws_exainfra_dbservers = module.exadata_infrastructure.db_servers

  # General settings
  vm_cluster_name = var.vmc_vm_cluster_name
  gi_cluster_name = var.vmc_gi_cluster_name
  time_zone       = var.vmc_time_zone
  license_model   = var.vmc_license_model
  # Infrastructure
  aws_odb_exa_resource_id = module.exadata_infrastructure.resource_id
  gi_version              = var.vmc_gi_version
  db_servers              = var.vmc_db_servers
  # Configuration
  cpu_core_count_per_vm              = var.vmc_cpu_core_count_per_vm
  memory_size_in_gbs_per_vm          = var.vmc_memory_size_in_gbs_per_vm
  db_node_storage_size_in_gbs_per_vm = var.vmc_db_node_storage_size_in_gbs_per_vm
  data_storage_size_in_tbs           = var.vmc_data_storage_size_in_tbs
  is_local_backup_enabled            = var.vmc_is_local_backup_enabled
  is_sparse_diskgroup_enabled        = var.vmc_is_sparse_diskgroup_enabled
  # Connectivity
  aws_odb_network_resource_id = var.vmc_odb_network_id
  hostname_prefix             = var.vmc_hostname_prefix
  scan_listener_port_tcp      = var.vmc_scan_listener_port_tcp
  ssh_public_keys             = var.vmc_vm_ssh_public_keys
  # Diagnostics and tags
  tags                          = merge(var.tags, { "Environment" : var.environment })
  is_diagnostics_events_enabled = var.vmc_is_diagnostics_events_enabled
  is_health_monitoring_enabled  = var.vmc_is_health_monitoring_enabled
  is_incident_logs_enabled      = var.vmc_is_incident_logs_enabled
}

# ================================================
# MONITORING MOVED TO STAGE 4 (4_monitoring/)
# ================================================
# cloudwatch_cluster_monitoring and cloudwatch_db_server_monitoring
# are now instantiated in the 4_monitoring stage using remote state
# outputs from this 2_compute stage.
# See: 4_monitoring/main.tf
