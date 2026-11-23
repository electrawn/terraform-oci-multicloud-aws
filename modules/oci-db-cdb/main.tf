# Create the OCI CDB
resource "oci_database_database" "this" {
  db_home_id = var.exa_db_home_ocid

  database {
    db_name        = var.db_name
    admin_password = var.db_admin_password
    db_backup_config {
      auto_backup_enabled = var.auto_backup

      auto_backup_window      = var.auto_backup_window      #"SLOT_FIVE"
      auto_full_backup_day    = var.auto_full_backup_day    #"MONDAY"
      auto_full_backup_window = var.auto_full_backup_window # "SLOT_FIVE"
      backup_deletion_policy  = var.backup_deletion_policy  #"DELETE_AFTER_RETENTION_PERIOD"
      backup_destination_details {
        type = var.backup_destination_type #"OBJECT_STORE"
      }
      recovery_window_in_days   = var.recovery_window_in_days   #"7"
      run_immediate_full_backup = var.run_immediate_full_backup #"true"
    }
    freeform_tags = var.tags
  }
  source = var.db_source
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      source,
      database
    ]
  }
}

