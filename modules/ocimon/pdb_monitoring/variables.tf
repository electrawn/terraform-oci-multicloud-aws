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
  description = "Additional resource tags for the pdb Monitoring"
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
variable "is_enabled_pdb_tablespace_utilization" {
  description = "Enable or disable the pdb Tablespace space utilization alarm (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_pdb_storage_utilization" {
  description = "Enable or disable the pdb Storage utilization alarm (warning + critical via overrides)"
  type        = bool
  default     = true
}
variable "is_enabled_pdb_processes_utilization" {
  description = "Enable or disable the pdb Processes utilization OCI alarm"
  type        = bool
  default     = true
}
variable "is_enabled_pdb_user_password_expiration" {
  description = "Enable or disable the pdb Monitoring user password expiration alarm (warning + critical via overrides)"
  type        = bool
  default     = false
}
variable "is_enabled_pdb_cpu_utilization" {
  description = "Enable or disable the pdb CPU utilization OCI alarm"
  type        = bool
  default     = true
}
variable "is_enabled_pdb_blocking_sessions_count" {
  description = "Enable or disable the pdb Blocking sessions count OCI alarm"
  type        = bool
  default     = true
}

variable "alarms_enabled" {
  type        = bool
  description = "Master switch to enable or disable all PDB alarms"
  default     = true
}

# Alarm Enabled Control
variable "in_downtime" {
  type        = bool
  description = "Flag to indicate if the system in downtime for maintenance"
  default     = false
}