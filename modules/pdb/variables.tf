variable "database_role" {
  description = "Operational role of the database. Controls DB Management and monitoring behavior."
  type        = string
  default     = "regular"

  validation {
    condition = contains([
      "template",
      "regular",
      "dataguard_primary",
      "dataguard_standby",
      "reporting"
    ], var.database_role)
    error_message = "database_role must be one of: template, regular, dataguard_primary, dataguard_standby, reporting."
  }
}

variable "enable_db_management" {
  description = "Enable database management registration. Set to false to skip if management enablement is failing."
  type        = bool
  default     = true
}

variable "private_end_point_ocid" {
  description = "OCID for DB Management Private End Point"
  type        = string
  default     = "ocid1.dbmgmtprivateendpoint.oc1.iad.exampleuniqueiddbmgmt0001"
}

variable "db_management_password_ocid" {
  description = "OCID for Vault Secret to DB password"
  type        = string
  default     = "ocid1.vaultsecret.oc1.iad.exampleuniqueidvaults0001"
}
# ------------------------
# Exadata module variables (kept as you shared)
# ------------------------
#variable "vm_cluster_display_name"  { type = string }
variable "exainfra_id" {
  description = "AWS ExaData infra ID for Oracle DB (AWS ID)"
  type        = string
}
variable "exainfra_ocid" {
  description = "OCI ExaData infra OCID"
  type        = string
}
variable "vm_cluster_id" {
  description = "AWS VM Cluster ID for Oracle DB (AWS ID)"
  type        = string
}
variable "vm_cluster_name" {
  description = "AWS VM Cluster Name"
  type        = string
}
variable "vm_cluster_ocid" {
  description = "OCI VM Cluster OCID"
  type        = string
}

variable "container_database_ocid" {
  description = "OCI Database CDB OCID"
  type        = string
}


variable "tags" {
  description = "Resource tags for the cdb monitoring"
  type        = map(string)
  default     = null
}
variable "compartment_ocid" {
  description = "OCID for compartment"
  type        = string
}


# ==================================Pluggable Database vars==========================
variable "pdb_name" {
  type        = string
  description = "The display name of the database. (required)"
}

variable "pdb_admin_password" {
  type        = string
  sensitive   = true
  default     = null
  description = "A strong password for SYS, SYSTEM, PDB Admin and TDE Wallet."
}

variable "pdb_tde_wallet_password" {
  type        = string
  sensitive   = true
  default     = null
  description = "A strong password for SYS, SYSTEM, PDB Admin and TDE Wallet."
}

variable "pdb_source" {
  type        = string
  default     = "NONE"
  description = "The source of the database (optional), default NONE."
}

variable "pdb_auto_backup_enabled" {
  type        = bool
  default     = false
  description = "Enable automatic backup (optional), default false"
}


variable "environment" {
  type        = string
  description = "Variable for environment (dev/prd)"
  default     = "prd"
}

variable "tenancy_ocid" {
  description = "OCI tenancy root OCID. When provided, an IAM deny-delete policy is created at the tenancy level that blocks DeletePluggableDatabase API calls on this specific PDB, supplementing prevent_destroy with OCI-native platform protection."
  type        = string
  default     = null
}

# ========================================================================
# MONITORING VARIABLES REMOVED - Use 4_monitoring stage instead
# ========================================================================
# The following monitoring-related variables have been removed:
#   - alarms_enabled
#   - ocimon_alarms_enabled
#   - is_enabled_ocimon_pdb_tablespace_utilization
#   - is_enabled_ocimon_pdb_storage_utilization
#   - is_enabled_ocimon_pdb_processes_utilization
#   - is_enabled_ocimon_pdb_user_password_expiration
#   - is_enabled_ocimon_pdb_cpu_utilization
#   - is_enabled_ocimon_pdb_blocking_sessions_count
#   - in_downtime (only used for monitoring)
#
# These are now configured in the dedicated 4_monitoring stage which
# reads this module's outputs and creates all alarm resources.
# ========================================================================
