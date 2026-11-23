# Create the OCI PDB
resource "oci_database_pluggable_database" "this" {
  container_database_id = var.container_database_ocid
  pdb_name              = var.pdb_name
  pdb_admin_password    = var.pdb_admin_password
  tde_wallet_password   = var.pdb_tde_wallet_password
  freeform_tags         = var.tags
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      pdb_admin_password,
      tde_wallet_password,
      container_database_admin_password,
      # The live pdb_name (assigned at creation, e.g. "PDB502") can differ
      # from the configured pdb_name. pdb_name forces replacement, which would
      # destroy a live PDB, so drift on it is ignored rather than reconciled.
      pdb_name,
    ]
  }
}