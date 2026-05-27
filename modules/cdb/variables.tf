variable "private_end_point_ocid" {
  description = "OCID for DB Management Private End Point"
  type        = string
  default     = null
}

variable "db_management_password_ocid" {
  description = "OCID for Vault Secret to DB password"
  type        = string
  default     = null
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

variable "db_home_ocid" {
  description = "OCI Database DB Home OCID"
  type        = string
}

variable "sns_alert_arn" {
  type        = string
  description = "ARN string for sending data to SNS notifications (changes by region)"
  default     = null
}

variable "destinations" {
  type        = list(string)
  description = "Notifications topics for alarms to send to by OCID"
  default     = []
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


# ==================================Container Database vars==========================
variable "cdb_name" {
  type        = string
  description = "The display name of the database. (required)"
}

variable "cdb_admin_password" {
  type        = string
  sensitive   = true
  description = "A strong password for SYS, SYSTEM, PDB Admin and TDE Wallet. (required)"
}

variable "cdb_source" {
  type        = string
  default     = "NONE"
  description = "The source of the database (optional), default NONE."
}

variable "cdb_auto_backup_enabled" {
  type        = bool
  default     = false
  description = "Enable automatic backup (optional), default false"
}

variable "notification_topic_ocid" {
  type    = string
  default = null
}


variable "auto_full_backup_day" {
  type        = string
  description = "The day of the week the full backup should be performed. Must be one of the specified ENUM values."
  default     = "SUNDAY"

  validation {
    condition = contains([
      "SUNDAY",
      "MONDAY",
      "TUESDAY",
      "WEDNESDAY",
      "THURSDAY",
      "FRIDAY",
      "SATURDAY"
    ], var.auto_full_backup_day)
    error_message = "The auto_full_backup_day must be an uppercase day ENUM (e.g., 'SUNDAY')."
  }
}

variable "auto_backup_window" {
  type        = string
  description = "The 2-hour window selected for initiating automatic backups. Must be an enum value (e.g., SLOT_ONE, SLOT_TWO)."
  default     = "SLOT_TWO" # Matches 2:00 AM - 4:00 AM

  validation {
    condition = contains([
      "SLOT_ONE",    # 12:00 AM - 2:00 AM
      "SLOT_TWO",    # 2:00 AM - 4:00 AM
      "SLOT_THREE",  # 4:00 AM - 6:00 AM
      "SLOT_FOUR",   # 6:00 AM - 8:00 AM
      "SLOT_FIVE",   # 8:00 AM - 10:00 AM
      "SLOT_SIX",    # 10:00 AM - 12:00 PM
      "SLOT_SEVEN",  # 12:00 PM - 2:00 PM
      "SLOT_EIGHT",  # 2:00 PM - 4:00 PM
      "SLOT_NINE",   # 4:00 PM - 6:00 PM
      "SLOT_TEN",    # 6:00 PM - 8:00 PM
      "SLOT_ELEVEN", # 8:00 PM - 10:00 PM
      "SLOT_TWELVE"  # 10:00 PM - 12:00 AM
    ], var.auto_backup_window)
    error_message = "The auto_backup_window must be one of the twelve defined SLOT enums (e.g., SLOT_ONE)."
  }
}

variable "auto_full_backup_window" {
  type        = string
  description = "The 2-hour window selected for initiating automatic backups. Must be an enum value (e.g., SLOT_ONE, SLOT_TWO)."
  default     = "SLOT_TWO" # Matches 2:00 AM - 4:00 AM

  validation {
    condition = contains([
      "SLOT_ONE",    # 12:00 AM - 2:00 AM
      "SLOT_TWO",    # 2:00 AM - 4:00 AM
      "SLOT_THREE",  # 4:00 AM - 6:00 AM
      "SLOT_FOUR",   # 6:00 AM - 8:00 AM
      "SLOT_FIVE",   # 8:00 AM - 10:00 AM
      "SLOT_SIX",    # 10:00 AM - 12:00 PM
      "SLOT_SEVEN",  # 12:00 PM - 2:00 PM
      "SLOT_EIGHT",  # 2:00 PM - 4:00 PM
      "SLOT_NINE",   # 4:00 PM - 6:00 PM
      "SLOT_TEN",    # 6:00 PM - 8:00 PM
      "SLOT_ELEVEN", # 8:00 PM - 10:00 PM
      "SLOT_TWELVE"  # 10:00 PM - 12:00 AM
    ], var.auto_full_backup_window)
    error_message = "The auto_full_backup_window must be one of the twelve defined SLOT enums (e.g., SLOT_ONE)."
  }
}

# --- Backup Configuration ---
variable "run_immediate_full_backup" {
  type        = bool
  description = "If true, OCI will manage automatic incremental backups."
  default     = null
}

variable "recovery_window_in_days" {
  type        = number
  description = "Retention period for backups. Must be between 7 and 95 days."
  default     = null

  #validation {
  #  condition     = var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 95
  #  error_message = "The recovery window must be between 7 and 95 days."
  #}
}

variable "backup_deletion_policy" {
  type        = string
  description = "Determines if backups are kept or deleted when the DB system is terminated."
  default     = "DELETE_AFTER_RETENTION_PERIOD"

  validation {
    condition     = contains(["DELETE_AFTER_RETENTION_PERIOD", "RETAIN_BACKUPS"], var.backup_deletion_policy)
    error_message = "Deletion policy must be either 'DELETE_AFTER_RETENTION_PERIOD' or 'RETAIN_BACKUPS'."
  }
}

variable "backup_destination_type" {
  type        = string
  description = "Type of backup destination. Typically 'OBJECT_STORE' or 'RECOVERY_SERVICE'."
  default     = "OBJECT_STORE"
}

variable "alarms_enabled" {
  type        = bool
  description = "Master switch to enable or disable CloudWatch alarms"
  default     = true
}

variable "environment" {
  type        = string
  description = "Variable for environment (dev/prd)"
  default     = "prd"
}

variable "in_downtime" {
  type        = bool
  description = "Flag to indicate if the system in downtime for maintenance"
  default     = false
}
