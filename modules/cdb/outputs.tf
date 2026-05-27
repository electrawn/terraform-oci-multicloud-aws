output "cdb_resource_id" {
  description = "Resource ID of CDB"
  value       = module.cdb.oci_resource_ocid
}

output "cdb_resource" {
  description = "CDB resource"
  value       = module.cdb.oci_resource
}

output "cdb_management_resource" {
  value = oci_database_cloud_database_management.cdb_management
}