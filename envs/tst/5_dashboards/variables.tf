variable "environment" {
  description = "Environment"
  type        = string
  default     = "tst"
}

variable "exainfra_id" {
  description = "AWS ExaData infra ID for Oracle DB (AWS ID). When null, resolved from 2_compute remote state."
  type        = string
  default     = null
}

variable "exainfra_ocid" {
  description = "OCI ExaData infra OCID. When null, resolved from 2_compute remote state."
  type        = string
  default     = null
}

variable "vm_cluster_id" {
  description = "AWS VM Cluster ID for Oracle DB (AWS ID). When null, resolved from 2_compute remote state."
  type        = string
  default     = null
}

variable "vm_cluster_name" {
  description = "AWS VM Cluster Name. When null, resolved from 2_compute remote state."
  type        = string
  default     = null
}

variable "vm_cluster_ocid" {
  description = "OCI VM Cluster OCID. When null, resolved from 2_compute remote state."
  type        = string
  default     = null
}

variable "cdb_databases" {
  description = "List of CDB database names for the CDB dashboard"
  type        = list(string)
  default = [
    "cdb057", "cdb068", "cdb027", "cdb015", "cdb060",
    "cdb069", "cdb062", "cdb017", "cdb031", "cdb051",
    "cdb005", "cdb026", "cdb055", "cdb056", "cdb071",
    "cdb067",
  ]
}

variable "pdb_databases" {
  description = "List of PDB database names for the PDB dashboard"
  type        = list(string)
  default = [
    "PDB510", "PDB026", "PDB505", "PDB512", "PDB513",
    "PDB060", "PDB506", "PDB511", "PDB507", "PDB501",
    "PDB053", "PDB055", "PDB056", "PDB066",
    "PDB064",
  ]
}

# ---------------------------------------------------------------------------
# ZDLAR (Recovery Service) protected databases -> one OCI dashboard each.
# Keyed by DB name; each value is the protected-database resource OCID
# (ocid1.recoveryserviceprotecteddatabase...). Populate as CDBs onboard.
# ---------------------------------------------------------------------------
# NOTE: typed as `any` (not map(string)) because the published registry module
# `ocimon-zdlar-dashboards` expects map(object) while the local override module
# expects map(string). `any` lets the (currently empty) value satisfy both the
# local override validation and the registry module used in CI. When ZDLAR
# databases are onboarded, populate this to match whichever module is active.
variable "zdlar_protected_databases" {
  description = "Map of DB name => protected-database resource OCID for OCI ZDLAR dashboards."
  type        = any
  default     = {}
}
