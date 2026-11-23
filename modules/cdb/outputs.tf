output "cdb_resource_id" {
  description = "Resource ID of CDB"
  value       = module.cdb.oci_resource_ocid
}

output "cdb_resource" {
  description = "CDB resource"
  value       = module.cdb.oci_resource
}

output "cdb_management_resource" {
  value = local.effective_enable_db_management ? oci_database_cloud_database_management.cdb_management[0] : null
}