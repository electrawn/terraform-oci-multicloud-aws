variable "compartment_ocid" {
  description = "OCID of the compartment where the management dashboards and saved searches are created."
  type        = string
}

variable "vm_cluster_name" {
  description = "VM cluster name, used for dashboard naming (e.g. exa1vmc1)."
  type        = string
}

variable "environment" {
  description = "Environment (sbx/dev/prd). Used in the dashboard display name."
  type        = string
  default     = "sbx"
}

variable "region" {
  description = "OCI region the oracle_oci_database metrics are emitted in (metric query region)."
  type        = string
  default     = "us-ashburn-1"
}

# ---------------------------------------------------------------------------
# CDB databases to chart. Keyed by DB name; each maps to the database OCID
# that the oracle_oci_database namespace keys on via the resourceId dimension.
# One dashboard is produced per entry.
# ---------------------------------------------------------------------------
variable "databases" {
  description = "Map of CDB databases (name => database OCID) to build OCI dashboards for."
  type        = map(string)
}

variable "dashboard_name_prefix" {
  description = "Prefix for each dashboard display name. Defaults to \"<vm_cluster_name>-CDB\"."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Optional: Recovery Service (ZDLRA) protected-database OCIDs, keyed by the
# SAME CDB name used in var.databases. When a CDB has an entry here, Recovery
# Service backup/health widgets (oci_recovery_service namespace) are appended
# to that CDB's dashboard. CDBs without an entry get the standard widget set
# only. Recovery Service metrics key on the protected-database OCID, which is
# distinct from the CDB database OCID.
# ---------------------------------------------------------------------------
variable "protected_databases" {
  description = "Optional map of CDB name => Recovery Service protected-database OCID for ZDLRA backup/health widgets."
  type        = map(string)
  default     = {}
}
