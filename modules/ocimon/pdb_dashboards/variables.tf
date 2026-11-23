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
# PDB databases to chart. Keyed by DB name; each maps to the database OCID
# that the oracle_oci_database namespace keys on via the resourceId dimension.
# One dashboard is produced per entry.
# ---------------------------------------------------------------------------
variable "databases" {
  description = "Map of PDB databases (name => database OCID) to build OCI dashboards for."
  type        = map(string)
}

variable "dashboard_name_prefix" {
  description = "Prefix for each dashboard display name. Defaults to \"<vm_cluster_name>-PDB\"."
  type        = string
  default     = ""
}
