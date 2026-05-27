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

variable "container_database_ocid" {
  description = "OCI Database CDB OCID"
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

variable "notification_topic_ocid" {
  type    = string
  default = null
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
