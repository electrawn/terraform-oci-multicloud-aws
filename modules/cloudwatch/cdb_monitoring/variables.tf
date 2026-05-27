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
variable "database_name" {
  description = "Database Name"
  type        = string
}
variable "database_ocid" {
  description = "OCI Database OCID"
  type        = string
}

variable "sns_alert_arn" {
  type        = string
  description = "ARN string for sending data to SNS notifications (changes by region)"
  default     = null
}
variable "environment" {
  type        = string
  description = "Variable for environment (dev/prd)"
  default     = "prd"
}
variable "alarms_enabled" {
  type        = bool
  description = "Master switch to enable or disable all CDB alarms"
  default     = true
}
variable "tags" {
  description = "Additional Resource tags for the cdb Monitoring"
  type        = map(string)
  default     = null
}

# ------------------------
# Per-alarm enable/disable flags
# ------------------------
variable "is_enabled_cdb_storage_utilization_warning" {
  description = "Enable or disable the cdb_storage_utilization_warning CloudWatch alarm"
  type        = bool
  default     = false
}
variable "is_enabled_cdb_storage_utilization_critical" {
  description = "Enable or disable the cdb_storage_utilization_critical CloudWatch alarm"
  type        = bool
  default     = false
}
variable "is_enabled_cdb_processes_utilization" {
  description = "Enable or disable the cdb_processes_utilization CloudWatch alarm"
  type        = bool
  default     = false
}
variable "is_enabled_cdb_user_password_expiration_warning" {
  description = "Enable or disable the cdb_Monitoring_user_password_expiration_warning CloudWatch alarm"
  type        = bool
  default     = false
}
variable "is_enabled_cdb_user_password_expiration_critical" {
  description = "Enable or disable the cdb_Monitoring_user_password_expiration_critical CloudWatch alarm"
  type        = bool
  default     = false
}
variable "is_enabled_cdb_monitor_status" {
  description = "Enable or disable the cdb_monitor_status CloudWatch alarm"
  type        = bool
  default     = true
}

variable "in_downtime" {
  type        = bool
  description = "Flag to indicate if the system is in downtime for maintenance. When true, alarms will not send notifications"
  default     = false
}
