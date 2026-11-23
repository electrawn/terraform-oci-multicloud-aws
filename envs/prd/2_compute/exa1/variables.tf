# Best Practice:
# Override most of these variables from Root main.tf file
#
#============Here and temp variables====================
variable "environment" {
  type    = string
  default = "prd"
}

#TODO: Remove when network consolidated
variable "vmc_odb_network_id" {
  type        = string
  description = "ODB Network ID"
}


#==================================AWS common vars==========================
variable "aws_region" {
  description = "AWS Region, e.g. us-west-2"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "AWS resources availability zone, e.g. us-west-2c"
  type        = string
  default     = null
}

variable "availability_zone_id" {
  description = "AWS resources availability zone ID, e.g. usw2-az3"
  type        = string
  default     = "use1-az4"
}

variable "tags" {
  description = "Default Tags to apply to resources"
  type        = map(string)
  default = {
    managed_by = "terraform",
    created_by = "terraform",
    Team       = "Database Team",
  }
}

#==================================Exadata Infrastructure vars================
variable "exadata_infrastructure_shape" {
  type        = string
  description = "Shape of Exadata Infrastructure"
  default     = "Exadata.X11M"
}

variable "exadata_infrastructure_name" {
  type        = string
  description = "Display name of Exadata Infrastructure"
}

variable "exadata_infrastructure_compute_count" {
  type        = number
  description = "Number of Compute Servers"
  default     = 2
}

variable "exadata_infrastructure_storage_count" {
  type        = number
  description = "Number of Storage Servers"
  default     = 3
}

variable "exadata_infrastructure_maintenance_window" {
  description = "Maintenance window configuration for the Exadata Infrastructure"
  type = object({
    patching_mode                    = string
    preference                       = string
    is_custom_action_timeout_enabled = optional(bool)
    custom_action_timeout_in_mins    = optional(number)
    days_of_week = optional(set(object(
      { name = string }
    )))
    hours_of_day       = optional(set(number))
    lead_time_in_weeks = optional(number)
    months = optional(set(object(
      { name = string }
    )))
    weeks_of_month = optional(set(number))
  })
  default = {
    patching_mode                    = "ROLLING"
    preference                       = "CUSTOM_PREFERENCE"
    is_custom_action_timeout_enabled = false
    custom_action_timeout_in_mins    = 0
  }
}

variable "exadata_infrastructure_customer_contacts" {
  type        = set(object({ email = string }))
  description = "List of customer contacts to send notifications to OCI"
  default     = [{ email = "user@example.com" }]
}

#Underlying Oracle Supplied TF module defaults to these values, kept for future.
#variable "exadata_infrastructure_database_type" = "X11M"
#varaible "exadata_infrastructure_storage_type  = "X11M-HC"

# ==================================VM Cluster vars==========================
variable "vmc_vm_cluster_name" {
  type        = string
  description = "The name of the Exadata VM Cluster (required)"
}

variable "vmc_gi_cluster_name" {
  type        = string
  description = "The name of the Grid Infrastructure (GI) Cluster (optional)"
  default     = null
}

variable "vmc_time_zone" {
  type        = string
  description = "The time zone of the Exadata VM cluster (optional), default: UTC"
  default     = "UTC"
}

variable "vmc_license_model" {
  type        = string
  description = "The Oracle license model to apply to the Exadata VM cluster (optional), BRING_YOUR_OWN_LICENSE (default) or BRING_YOUR_OWN_LICENSE"
  default     = "BRING_YOUR_OWN_LICENSE"
}

variable "vmc_gi_version" {
  type        = string
  description = "The major version of Grid Infrastructure (GI) to install (optional), default 23.0.0.0."
  default     = "23.0.0.0"
}

variable "vmc_db_servers" {
  type        = set(string)
  description = "List of DB server IDs (optional), default: null means all DB servers in the Exadata Infrastructure will be used"
  default     = null
}

variable "vmc_cpu_core_count_per_vm" {
  type        = number
  description = "The number of CPU cores to enable per VM for the Exadata VM cluster (optional). Minimum 8 for X11M, default 8"
  default     = 8
}

variable "vmc_memory_size_in_gbs_per_vm" {
  type        = number
  description = "The size of memory in GBs to enable per VM for the Exadata VM cluster (optional). Minimum: 30 per VM, default: 30"
  default     = 30
}

variable "vmc_db_node_storage_size_in_gbs_per_vm" {
  type        = number
  description = "The size of the database node storage in GBs to enable per VM for the Exadata VM cluster (optional). Minimum: 60 per VM, default: 60"
  default     = 60
}

variable "vmc_data_storage_size_in_tbs" {
  type        = number
  description = "The size of the data storage in TBs to enable for the Exadata VM cluster (optional), default: 2"
  default     = 2
}

variable "vmc_is_local_backup_enabled" {
  type        = bool
  description = "Specifies whether local database backup is enabled for the Exadata VM cluster (optional), default: false"
  default     = false
}
variable "vmc_is_sparse_diskgroup_enabled" {
  type        = bool
  description = "Specifies whether sparse disk groups are enabled for the Exadata VM cluster (optional), default: false"
  default     = false
}
variable "vmc_hostname_prefix" {
  type        = string
  description = "The hostname prefix to use for the Exadata VM cluster, default: vmc. The host name must not exceed 12 characters and must start with a letter. Valid characters are A-Z, a-z, 0-9, and hyphen (-)."
  default     = "exa1vmc1"
}
variable "vmc_vm_ssh_public_keys" {
  type        = set(string)
  description = "String of SSH keys"
}
variable "vmc_scan_listener_port_tcp" {
  type        = number
  description = "The SCAN listener port for TCP protocol (optional), default: 1521"
  default     = 1521
}
variable "vmc_is_diagnostics_events_enabled" {
  type        = bool
  description = "Specifies whether the Oracle Cloud Infrastructure (OCI) Diagnostics events are enabled for the Exadata VM cluster (optional), default: true"
  default     = true
}
variable "vmc_is_health_monitoring_enabled" {
  type        = bool
  description = "Specifies whether the Health Monitoring service is enabled for the Exadata VM cluster (optional), default: true"
  default     = true
}
variable "vmc_is_incident_logs_enabled" {
  type        = bool
  description = "Specifies whether the Incident Logs service is enabled for the Exadata VM cluster (optional), default: true"
  default     = true
}
variable "opsgenie_alert_arn" {
  type        = string
  description = "ARN for sending alerts to Opsgenie via SNS"
  default     = "arn:aws:sns:us-east-1:222222222222:EventBrokerSNS-prd"
}

variable "enable_inline_monitoring" {
  description = "Create CloudWatch monitoring modules in this stage"
  type        = bool
  default     = true
}

