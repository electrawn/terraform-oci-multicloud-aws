
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

output "db_servers" {
  value = module.exadata_infrastructure.db_servers
}

output "db_nodes" {
  value = module.exadata_vm_cluster.db_nodes
}

output "vm_cluster_resource" {
  value = module.exadata_vm_cluster.resource
}
