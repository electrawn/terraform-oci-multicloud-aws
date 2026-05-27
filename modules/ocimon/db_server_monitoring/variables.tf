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
variable "is_enabled_vm_cluster_cpu" {
  description = "Enable or disable the vm_cluster_cpu alarm"
  type        = bool
  default     = false
}
variable "is_enabled_vm_cluster_memory" {
  description = "Enable or disable the vm_cluster_memory alarm"
  type        = bool
  default     = false
}
variable "is_enabled_node_status" {
  description = "Enable or disable the node_status alarm"
  type        = bool
  default     = true
}

variable "is_enabled_filesystem_utilization" {
  description = "Master switch to enable or disable all filesystem alarms (each alarm has warning + critical via overrides)"
  type        = bool
  default     = true
}

variable "is_enabled_u01_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /u01 (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_crashfiles_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /crashfiles (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_var_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /var (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_boot_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /boot (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_root_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for / (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_var_log_audit_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /var/log/audit (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_home_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /home (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_acfs01_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /acfs01 (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_u02_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /u02 (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_tmp_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /tmp (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_u01_app_grid_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /u01/app/23.0.0.0/grid (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_var_log_filesystem_utilization" {
  description = "Enable or disable filesystem alarm for /var/log (warning + critical via overrides)"
  type        = bool
  default     = true
}

variable "alarms_enabled" {
  type        = bool
  description = "Master switch to enable or disable all DB server alarms"
  default     = true
}

variable "in_downtime" {
  type        = bool
  description = "Flag to indicate if the system is in downtime for maintenance. When true, alarms will be disabled"
  default     = false
}
