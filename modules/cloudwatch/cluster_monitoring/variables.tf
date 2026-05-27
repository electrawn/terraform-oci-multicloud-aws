# ------------------------
# Exadata module variables (kept as you shared)
# ------------------------
#variable "vm_cluster_display_name"  { type = string }
variable "exainfra_id" {
  description = "AWS ExaData infra ID for Oracle DB (AWS ID)"
  type        = string
}
variable "vm_cluster_id" {
  description = "AWS VM Cluster ID for Oracle DB (AWS ID)"
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
# ------------------------
# Per-alarm enable/disable flags
# ------------------------
variable "is_enabled_asm_storage_data1" {
  description = "Enable or disable the asm_storage_data1 CloudWatch alarm"
  type        = bool
  default     = true
}
variable "is_enabled_asm_storage_reco1" {
  description = "Enable or disable the asm_storage_reco1 CloudWatch alarm"
  type        = bool
  default     = true
}

variable "in_downtime" {
  type        = bool
  description = "Flag to indicate if the system is in downtime for maintenance. When true, alarms will not send notifications"
  default     = false
}
