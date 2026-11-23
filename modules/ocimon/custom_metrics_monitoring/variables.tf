# ---------------------------------------------------------------------------
# ocimon/custom_metrics_monitoring
#
# OCI Monitoring alarms for the custom metric namespace emitted by the
# oci-functions project: "example_oracledb_aws".
#
#   sshstatus                       (per DB node)       0 = OK, 1 = FAILED
#   oracle_service_status           (per database)      0 = OK, 1 = FAILED
#   libcache_mutex_waiting_sessions (per RAC instance)  sessions waiting >= 15 min on library cache: mutex X
#
# sshstatus / oracle_service_status fire on FAILED (> 0).
# libcache_mutex fires at P4 when a 15-minute datapoint is at or above the threshold.
# ---------------------------------------------------------------------------

variable "exainfra_id" {
  description = "AWS ExaData infra ID (used to self-discover DB nodes)."
  type        = string
}

variable "vm_cluster_id" {
  description = "AWS VM Cluster ID (used to self-discover DB nodes)."
  type        = string
}

variable "vm_cluster_name" {
  description = "VM cluster name, used in alarm display names and entity labels."
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the compartment where the custom metrics are published and alarms are created."
  type        = string
}

variable "environment" {
  description = "Environment (sbx/dev/prd)."
  type        = string
  default     = "sbx"
}

variable "destinations" {
  description = "OCI ONS topic OCIDs the alarms notify."
  type        = list(string)
  default     = []
}

variable "metric_namespace" {
  description = "Custom metric namespace emitted by oci-functions."
  type        = string
  default     = "example_oracledb_aws"
}

# --- databases to monitor for oracle_service_status (service name => any
#     metadata; only the key/name is used as the database_name dimension). ---
variable "oracle_service_databases" {
  description = "List of database service names (oracle_service_status database_name dimension) to alarm on. Plain/legacy checks; for reporting PDBs and CPH services use reporting_service_databases / cph_services."
  type        = list(string)
  default     = []
}

# REPORTING service checks: lowercase PDB name => the read-only service it
# provides (the service is what the oci-function logs in to). One alarm per
# PDB, named <cluster>-<pdb>-reporting-service-status.
variable "reporting_service_databases" {
  description = "Map of reporting PDB name (lowercase; the metric database_name dimension) to the connect service the check tests."
  type        = map(string)
  default     = {}
}

# CPH service checks: service name => standby DB unique name. One alarm per
# service, named <cluster>-<service>-service-status.
variable "cph_services" {
  description = "Map of CPH connect service name (the metric database_name/service_name dimension) to the Data Guard standby DB unique name it runs on."
  type        = map(string)
  default     = {}
}

variable "is_enabled_reporting_service_status" {
  description = "Enable the per-PDB reporting-service-status alarms."
  type        = bool
  default     = true
}

variable "is_enabled_cph_service_status" {
  description = "Enable the per-service CPH service-status alarms."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Enable toggles
# ---------------------------------------------------------------------------
variable "ocimon_alarms_enabled" {
  description = "Master switch for all custom-namespace alarms in this module."
  type        = bool
  default     = false
}

variable "is_enabled_sshstatus" {
  description = "Enable the per-node sshstatus alarm."
  type        = bool
  default     = true
}

variable "is_enabled_oracle_service_status" {
  description = "Enable the per-database oracle_service_status alarm."
  type        = bool
  default     = true
}

variable "is_enabled_libcache_waiting_sessions" {
  description = "Enable the per-PDB libcache_mutex (P4) alarms. Name kept for caller compatibility."
  type        = bool
  default     = true
}

variable "libcache_databases" {
  description = "PDB service names (libcache_mutex_waiting_sessions database_name dimension) to create one libcache_mutex alarm per PDB. Empty = fall back to oracle_service_databases."
  type        = list(string)
  default     = []
}

variable "libcache_warning_threshold" {
  description = "Sessions WAITING >= 15 min on 'library cache: mutex X' per RAC instance at or above which a datapoint counts as breaching. The libcache_mutex P4 alarm fires after 4 consecutive breaching 15-minute datapoints (1 hour), and clears once a datapoint drops below this value. Name kept for caller compatibility."
  type        = number
  default     = 3
}

variable "libcache_critical_threshold" {
  description = "Deprecated/unused: libcache_mutex has a single per-PDB P4 alarm (no critical). Retained for caller compatibility."
  type        = number
  default     = 50
}

variable "libcache_mutex_docs_link" {
  description = "Runbook linked from the libcache_mutex alarm notification."
  type        = string
  default     = "https://wiki.example.com/docs/page-012"
}

variable "in_downtime" {
  description = "When true, alarms are created but disabled (maintenance)."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# OpsGenie / tagging metadata (mirrors the other ocimon modules)
# ---------------------------------------------------------------------------

variable "support_category" {
  type    = string
  default = "Database"
}

variable "support_teams" {
  type    = string
  default = "EXAMPLE_ONCALL_TEAM"
}

variable "docs_link" {
  type    = string
  default = "https://wiki.example.com/docs/page-013"
}

variable "tag_team" {
  type    = string
  default = "Database Team"
}

variable "tag_created_by" {
  type    = string
  default = "Database"
}

variable "tags" {
  description = "Additional freeform tags."
  type        = map(string)
  default     = null
}
