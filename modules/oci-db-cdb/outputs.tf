output "oci_resource_ocid" {
  value       = oci_database_database.this.id
  description = "The OCID of the Container Database"
}

output "oci_resource" {
  value       = oci_database_database.this
  description = "The resource object of the Container Database"
}
/*
output "oci_management_resource"  {
  value = oci_database_cloud_database_management.cdb_management
  description = "The resource object of the Database Management"
}

output "oci_management_ocid"  {
  value = oci_database_cloud_database_management.cdb_management.id
  description = "The OCID of Database Management for the CDB"
}
*/