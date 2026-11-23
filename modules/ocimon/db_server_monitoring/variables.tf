# ------------------------
# Exadata module variables (kept as you shared)
# ------------------------
#variable "vm_cluster_display_name"  { type = string }
variable "exainfra_id" {
  description = "AWS ExaData infra ID for Oracle DB (AWS ID)"
  type        = string
}
variable "exainfra_name" {
  description = "AWS ExaData infra Name"
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
variable "db_server_id" {
  description = "AWS DB Server ID for Oracle DB (AWS ID)"
  type        = string
  default     = null
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
  description = "Additional resource tags for DB server monitoring"
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
variable "is_enabled_ocimon_vm_cluster_cpu" {
  description = "Enable or disable the vm_cluster_cpu alarm"
  type        = bool
  default     = false
}
variable "is_enabled_ocimon_vm_cluster_memory" {
  description = "Enable or disable the vm_cluster_memory alarm"
  type        = bool
  default     = false
}
variable "is_enabled_ocimon_node_status" {
  description = "Enable or disable the node_status alarm"
  type        = bool
  default     = true
}

variable "is_enabled_ocimon_filesystem_utilization" {
  description = "Master switch to enable or disable all filesystem alarms (each alarm has warning + critical via overrides)"
  type        = bool
  default     = true
}

variable "is_enabled_ocimon_u01_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /u01 (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_ocimon_crashfiles_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /crashfiles (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_ocimon_var_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /var (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_ocimon_boot_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /boot (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_ocimon_root_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for / (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_ocimon_var_log_audit_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /var/log/audit (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_ocimon_home_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /home (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_ocimon_acfs01_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /acfs01 (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_ocimon_u02_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /u02 (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_ocimon_tmp_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /tmp (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_ocimon_u01_app_grid_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /u01/app/23.0.0.0/grid (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_ocimon_var_log_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /var/log (warning + critical via overrides)"
  type        = bool
  default     = true
}

variable "ocimon_alarms_enabled" {
  type        = bool
  description = "Master switch to enable or disable all OCIMON DB server alarms"
  default     = false
}

variable "in_downtime" {
  type        = bool
  description = "Flag to indicate if the system is in downtime for maintenance. When true, alarms will be disabled"
  default     = false
}
