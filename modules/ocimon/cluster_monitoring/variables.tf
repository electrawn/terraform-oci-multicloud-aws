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
variable "opsgenie_alert_arn" {
  type        = string
  description = "ARN string for sending data to Opsgenie (changes by region)"
  default     = "arn:aws:sns:us-east-1:222222222222:EventBrokerSNS-stg"
}
variable "docs_link" {
  type        = string
  description = "Link to Runbook page for alarm"
  default     = "https://wiki.example.com/docs/page-006"
}
variable "environment" {
  type        = string
  description = "Variable for environment (dev/prd)"
  default     = "prd"
}
variable "support_category" {
  type        = string
  description = "Variable for support category for OpsGenie"
  default     = "Database"
}
variable "tag_team" {
  type        = string
  description = "Variable for AWS tag resource Team Name"
  default     = "Database Team"
}
variable "tag_created_by" {
  type        = string
  description = "Variable for AWS tag resource Created By"
  default     = "Database"
}
variable "support_teams" {
  type        = string
  description = "Variable for support team (call queue) for OpsGenie"
  default     = "EXAMPLE_ONCALL_TEAM"
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
variable "is_enabled_ocimon_asm_storage_data1" {
  description = "Enable or disable the asm_storage_data1 OCIMON alarm"
  type        = bool
  default     = true
}
variable "is_enabled_ocimon_asm_storage_reco1" {
  description = "Enable or disable the asm_storage_reco1 OCIMON alarm"
  type        = bool
  default     = true
}

variable "ocimon_alarms_enabled" {
  type        = bool
  description = "Master switch to enable or disable all OCIMON cluster alarms"
  default     = false
}

variable "in_downtime" {
  type        = bool
  description = "Flag to indicate if the system is in downtime for maintenance. When true, alarms will not send notifications"
  default     = false
}
