module "pdb" {
  source                  = "./modules/oci-db-pdb"
  container_database_ocid = var.container_database_ocid
  pdb_name                = var.pdb_name
  pdb_admin_password      = var.pdb_admin_password
  pdb_tde_wallet_password = var.pdb_tde_wallet_password
  tags                    = var.tags

}

locals {
  service_name = split("/", module.pdb.oci_resource.connection_strings[0].pdb_default)

  # Role takes precedence; legacy variable used as override only if role is not "reporting"
  effective_enable_db_management = (
    var.database_role != "reporting"
    ? var.enable_db_management
    : false
  )
}


resource "oci_database_pluggable_database_pluggabledatabasemanagements_management" "pdb_management" {
  count                = local.effective_enable_db_management ? 1 : 0
  private_end_point_id = var.private_end_point_ocid
  service_name         = local.service_name[1]
  credential_details {
    password_secret_id = var.db_management_password_ocid
    user_name          = "dbsnmp"
  }
  enable_pluggabledatabasemanagement = true
  pluggable_database_id              = module.pdb.oci_resource_ocid
  lifecycle {
    ignore_changes = [
      connection_strings, pluggable_database_management_config, defined_tags, freeform_tags
    ]
  }
}

# ========================================================================
# OCI IAM No-Delete Policy Guard
# Supplements lifecycle.prevent_destroy with an OCI-native IAM deny policy
# that blocks DeletePluggableDatabase API calls on this specific PDB OCID
# at the platform level — independent of Terraform state.
#
# Activation: set tenancy_ocid in the module call.
# Removal: requires explicit terraform destroy of this policy resource
#          (also protected by prevent_destroy) before PDB decommission.
# ========================================================================
resource "oci_identity_policy" "pdb_no_delete_guard" {
  count          = var.tenancy_ocid != null ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = "no-delete-pdb-${lower(replace(var.pdb_name, "_", "-"))}"
  description    = "IAM guard: denies DeletePluggableDatabase on PDB ${var.pdb_name} (${module.pdb.oci_resource_ocid}). Must be removed by Lead DBA before decommission."
  statements = [
    "deny any-user to manage database-family in tenancy where all {target.resource.id = '${module.pdb.oci_resource_ocid}', request.operation = 'DeletePluggableDatabase'}"
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
# The 4_monitoring stage will create alarms based on this PDB's resource
# information. This module now focuses solely on database creation and
# database management registration.
# ========================================================================
