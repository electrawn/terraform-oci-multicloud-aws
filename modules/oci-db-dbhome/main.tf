# Create the OCI database DB home
resource "oci_database_db_home" "this" {
  vm_cluster_id               = var.vm_cluster_ocid
  db_system_id                = var.db_system_ocid
  source                      = var.db_home_source
  display_name                = var.db_home_name
  db_version                  = var.db_home_version
  is_desupported_version      = var.is_desupported_version
  database_software_image_id  = var.database_software_image_id
  is_unified_auditing_enabled = true

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      source
    ]
  }
}