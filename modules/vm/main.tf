data "aws_odb_db_servers" "all" {
  cloud_exadata_infrastructure_id = var.cloud_exadata_infrastructure_id
}

locals {
  final_db_servers = sort([
    for s in data.aws_odb_db_servers.all.db_servers : s.id
  ])
}

resource "aws_odb_cloud_vm_cluster" "this" {
  display_name                    = var.vmc_display_name
  cluster_name                    = var.cluster_name
  cloud_exadata_infrastructure_id = var.cloud_exadata_infrastructure_id

  cpu_core_count  = var.cpu_core_count
  gi_version      = var.gi_version
  hostname_prefix = var.hostname_prefix
  ssh_public_keys = var.ssh_public_keys
  odb_network_id  = var.odb_network_id

  is_local_backup_enabled     = var.is_local_backup_enabled
  is_sparse_diskgroup_enabled = var.is_sparse_diskgroup_enabled
  license_model               = var.license_model

  data_storage_size_in_tbs    = var.data_storage_size_in_tbs
  db_node_storage_size_in_gbs = var.db_node_storage_size_in_gbs
  memory_size_in_gbs          = var.memory_size_in_gbs

  # Auto-discovered DB servers
  db_servers = local.final_db_servers

  timezone = var.timezone
  tags     = var.tags

  data_collection_options {
    is_diagnostics_events_enabled = var.data_collection_options.is_diagnostics_events_enabled
    is_health_monitoring_enabled  = var.data_collection_options.is_health_monitoring_enabled
    is_incident_logs_enabled      = var.data_collection_options.is_incident_logs_enabled
  }

  lifecycle {
    ignore_changes = [
      cpu_core_count,
      gi_version,
      hostname_prefix,
      cluster_name,
      data_storage_size_in_tbs,
      db_node_storage_size_in_gbs,
      memory_size_in_gbs,
      ssh_public_keys,
      db_servers
    ]
    prevent_destroy = true
  }
}

