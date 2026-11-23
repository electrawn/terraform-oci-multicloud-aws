variable "environment" {
  description = "Environment"
  type        = string
  default     = "prd"
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
  default     = []
}

variable "pdb_databases" {
  description = "List of PDB database names for the PDB dashboard"
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# Multi-cluster configuration.
#
# prd runs three Exadata clusters (exa1, exa2, exa3). This map drives the
# individual per-CDB / per-PDB dashboards for every cluster at once.
#
# Each key is a cluster selector matching the 2_compute remote-state output
# prefix (exa1 / exa2 / exa3). Cluster IDs are resolved from remote state in
# locals.tf; only the database name lists need to be supplied here.
# ---------------------------------------------------------------------------
variable "clusters" {
  description = "Per-cluster CDB/PDB database lists for the individual dashboards. Keyed by compute output prefix (exa1/exa2/exa3)."
  type = map(object({
    cdb_databases = list(string)
    pdb_databases = list(string)
  }))
  default = {}
}

# ---------------------------------------------------------------------------
# ZDLAR (Recovery Service) protected databases -> one OCI dashboard each.
# Keyed by DB name; each needs the protected database OCID (resourceId) and
# each value is the protected-database resource OCID
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

