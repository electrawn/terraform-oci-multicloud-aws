output "pdb_resource_id" {
  description = "Resource ID of CDB"
  value       = module.pdb.oci_resource_ocid
}

output "pdb_resource" {
  description = "CDB resource"
  value       = module.pdb.oci_resource
}

output "pdb_management_resource" {
  value = oci_database_pluggable_database_pluggabledatabasemanagements_management.pdb_management
}