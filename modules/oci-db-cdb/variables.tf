variable "exa_db_home_ocid" {
  type        = string
  description = "The OCID of the Exadata DB Home"
}

variable "db_name" {
  type        = string
  description = "The name of the database"
}

variable "db_admin_password" {
  type        = string
  sensitive   = true
  description = "The administrator password for the database"
}

variable "db_source" {
  type        = string
  default     = "NONE"
  description = "The source of the database. Possible values are NONE, DB_BACKUP, DATABASE, or CROSS_REGION_DATAGUARD"
}

variable "auto_backup" {
  type        = bool
  default     = false
  description = "Whether auto back enabled for container databases."
}

variable "tags" {
  type        = map(string)
  description = "Freeform Tags for DB"
  default     = {}
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