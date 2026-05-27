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
variable "environment" {
  type        = string
  description = "Variable for environment (dev/prd)"

}
variable "destinations" {
  type        = list(string)
  description = "Notifications topics for alarms to send to by OCID"
  default     = []
}

variable "tags" {
  description = "Additional resource tags for cluster monitoring"
  type        = map(string)
  default     = null
}

variable "compartment_ocid" {
  description = "OCID for compartment"
  type        = string
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

variable "alarms_enabled" {
  type        = bool
  description = "Master switch to enable or disable all cluster alarms"
  default     = true
}

variable "in_downtime" {
  type        = bool
  description = "Flag to indicate if the system is in downtime for maintenance. When true, alarms will not send notifications"
  default     = false
}
