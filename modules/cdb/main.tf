module "cdb" {
  source            = "./modules/oci-db-cdb"
  exa_db_home_ocid  = var.db_home_ocid
  db_name           = var.cdb_name
  db_admin_password = var.cdb_admin_password
  db_source         = var.cdb_source

  auto_backup             = var.cdb_auto_backup_enabled
  auto_backup_window      = var.auto_backup_window      #"SLOT_FIVE"
  auto_full_backup_day    = var.auto_full_backup_day    #"MONDAY"
  auto_full_backup_window = var.auto_full_backup_window # "SLOT_FIVE"
  backup_deletion_policy  = var.backup_deletion_policy  #"DELETE_AFTER_RETENTION_PERIOD"
  backup_destination_type = var.backup_destination_type #"OBJECT_STORE"

  recovery_window_in_days   = var.recovery_window_in_days   #"7"
  run_immediate_full_backup = var.run_immediate_full_backup #"true"
  tags                      = var.tags
}

locals {

  service_name = split("/", module.cdb.oci_resource.connection_strings[0].cdb_default)

  # Role takes precedence; reporting databases never get DB Management regardless of enable_db_management
  effective_enable_db_management = (
    var.database_role != "reporting"
    ? var.enable_db_management
    : false
  )
}


resource "oci_database_cloud_database_management" "cdb_management" {
  count                = local.effective_enable_db_management ? 1 : 0
  database_id          = module.cdb.oci_resource_ocid
  private_end_point_id = var.private_end_point_ocid
  service_name         = local.service_name[1] #["cdb_default"]
  management_type      = "ADVANCED"
  credentialdetails {
    password_secret_id = var.db_management_password_ocid
    user_name          = "dbsnmp"
  }
  enable_management = true
}

# ========================================================================
# OCI IAM No-Delete Policy Guard
# Supplements lifecycle.prevent_destroy with an OCI-native IAM deny policy
# that blocks DeleteDatabase API calls on this specific CDB OCID at the
# platform level — independent of Terraform state.
#
# Activation: set tenancy_ocid in the module call.
# Removal: requires explicit terraform destroy of this policy resource
#          (also protected by prevent_destroy) before database decommission.
# ========================================================================
resource "oci_identity_policy" "cdb_no_delete_guard" {
  count          = var.tenancy_ocid != null ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = "no-delete-cdb-${lower(replace(var.cdb_name, "_", "-"))}"
  description    = "IAM guard: denies DeleteDatabase on CDB ${var.cdb_name} (${module.cdb.oci_resource_ocid}). Must be removed by Lead DBA before decommission."
  statements = [
    "deny any-user to manage database-family in tenancy where all {target.resource.id = '${module.cdb.oci_resource_ocid}', request.operation = 'DeleteDatabase'}"
  ]
  lifecycle {
    prevent_destroy = true
  }
}

# ========================================================================
# MONITORING DECOUPLED - Moved to dedicated 4_monitoring stage
# ========================================================================
# CloudWatch and OCI Monitoring modules are now instantiated in a
# separate Terraform stage (4_monitoring) that depends on this module's
# outputs. This decouples database provisioning from monitoring.
#
# The 4_monitoring stage will create alarms based on this CDB's resource
# information. This module now focuses solely on database creation and
# database management registration.
# ========================================================================

