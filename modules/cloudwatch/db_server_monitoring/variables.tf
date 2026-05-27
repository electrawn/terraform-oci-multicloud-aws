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
variable "db_servers" {
  type        = list(string)
  description = "list of DB Servers node ids from VMCluster resource"
}
variable "aws_exainfra_dbservers" {
  #TODO: Dial down via Object() def from aws_odb_db_servers
  type        = any
  description = "DataSource from aws_odb_db_servers"
}
variable "aws_vmcluster_dbnodes" {
  #TODO: Dial down via Object() def from aws_odb_db_nodes
  type        = any
  description = "DataSource from aws_odb_db_nodes"
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
variable "is_enabled_vm_cluster_cpu" {
  description = "Enable or disable the vm_cluster_cpu CloudWatch alarm"
  type        = bool
  default     = false
}
variable "is_enabled_vm_cluster_memory" {
  description = "Enable or disable the vm_cluster_memory CloudWatch alarm"
  type        = bool
  default     = false
}
variable "is_enabled_node_status" {
  description = "Enable or disable the node_status CloudWatch alarm"
  type        = bool
  default     = true
}
variable "is_enabled_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarms"
  type        = bool
  default     = true
}
variable "is_enabled_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarms"
  type        = bool
  default     = true
}
variable "is_enabled_u01_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarm for u01 mount point"
  type        = bool
  default     = true
}
variable "is_enabled_u01_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarm for /u01 mount point"
  type        = bool
  default     = true
}
variable "is_enabled_crashfiles_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarm for /crashfiles mount point"
  type        = bool
  default     = true
}
variable "is_enabled_crashfiles_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarm for /crashfiles mount point"
  type        = bool
  default     = true
}
variable "is_enabled_var_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarm for /var mount point"
  type        = bool
  default     = true
}
variable "is_enabled_var_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarm for /var mount point"
  type        = bool
  default     = true
}
variable "is_enabled_boot_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarm for /boot mount point"
  type        = bool
  default     = true
}
variable "is_enabled_boot_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarm for /boot mount point"
  type        = bool
  default     = true
}
variable "is_enabled_root_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarm for / mount point"
  type        = bool
  default     = true
}
variable "is_enabled_root_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarm for / mount point"
  type        = bool
  default     = true
}
variable "is_enabled_var_log_audit_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarm for /var/log/audit mount point"
  type        = bool
  default     = true
}
variable "is_enabled_var_log_audit_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarm for /var/log/audit mount point"
  type        = bool
  default     = true
}
variable "is_enabled_home_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarm for /home mount point"
  type        = bool
  default     = true
}
variable "is_enabled_home_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarm for /home mount point"
  type        = bool
  default     = true
}
variable "is_enabled_acfs01_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarm for /acfs01 mount point"
  type        = bool
  default     = true
}
variable "is_enabled_acfs01_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarm for /acfs01 mount point"
  type        = bool
  default     = true
}
variable "is_enabled_u02_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarm for /u02 mount point"
  type        = bool
  default     = true
}
variable "is_enabled_u02_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarm for /u02 mount point"
  type        = bool
  default     = true
}
variable "is_enabled_tmp_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarm for /tmp mount point"
  type        = bool
  default     = true
}
variable "is_enabled_tmp_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarm for /tmp mount point"
  type        = bool
  default     = true
}
variable "is_enabled_u01_app_grid_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarm for /u01/app/23.0.0.0/grid mount point"
  type        = bool
  default     = true
}
variable "is_enabled_u01_app_grid_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarm for /u01/app/23.0.0.0/grid mount point"
  type        = bool
  default     = true
}
variable "is_enabled_var_log_filesystem_utilization_crit" {
  description = "Enable or disable all filesystem critical CloudWatch alarm for /var/log mount point"
  type        = bool
  default     = true
}
variable "is_enabled_var_log_filesystem_utilization_warning" {
  description = "Enable or disable all filesystem warning CloudWatch alarm for /var/log mount point"
  type        = bool
  default     = true
}

variable "in_downtime" {
  type        = bool
  description = "Flag to indicate if the system is in downtime for maintenance. When true, alarms will not send notifications"
  default     = false
}
