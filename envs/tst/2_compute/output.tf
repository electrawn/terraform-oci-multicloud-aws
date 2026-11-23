output "exainfra_id" {
  value = module.exadata_infrastructure.resource_id
}

output "exainfra_ocid" {
  value = module.exadata_infrastructure.oci_resource_ocid
}

output "exainfra_display_name" {
  value = module.exadata_infrastructure.resource.display_name
}

output "vm_cluster_id" {
  value = module.exadata_vm_cluster.resource_id
}

output "vm_cluster_name" {
  value = module.exadata_vm_cluster.resource.display_name
}

output "vm_cluster_ocid" {
  value = module.exadata_vm_cluster.oci_resource_ocid
}

output "compartment_ocid" {
  description = "Compartment OCID for compute infrastructure"
  value       = module.exadata_infrastructure.oci_compartment_ocid
}

# Additional outputs needed by 4_monitoring stage
output "db_servers" {
  description = "DB servers from exadata infrastructure (needed by cloudwatch_db_server_monitoring)"
  value       = module.exadata_infrastructure.db_servers
}

output "db_nodes" {
  description = "DB nodes from VM cluster (needed by cloudwatch_db_server_monitoring)"
  value       = module.exadata_vm_cluster.db_nodes
}

output "vm_cluster_resource" {
  description = "Full VM cluster resource object (for cluster_name and other attributes)"
  value       = module.exadata_vm_cluster.resource
}

