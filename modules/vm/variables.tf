variable "vmc_display_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cloud_exadata_infrastructure_id" {
  description = "Derived automatically from exainfra (do not supply in tfvars)"
  type        = string
}

variable "cpu_core_count" {
  type = number
}

variable "gi_version" {
  type = string
}

variable "hostname_prefix" {
  type = string
}

variable "ssh_public_keys" {
  type = list(string)
}

variable "odb_network_id" {
  type = string
}

variable "is_local_backup_enabled" {
  type    = bool
  default = true
}

variable "is_sparse_diskgroup_enabled" {
  type    = bool
  default = false
}

variable "license_model" {
  type    = string
  default = "LICENSE_INCLUDED"
}

variable "data_storage_size_in_tbs" {
  type = number
}

variable "db_servers" {
  description = "Optional; if null, auto-discover all DB servers"
  type        = list(string)
  default     = null
}

variable "db_node_storage_size_in_gbs" {
  type = number
}

variable "memory_size_in_gbs" {
  type = number
}

variable "timezone" {
  type    = string
  default = "UTC"
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "data_collection_options" {
  type = object({
    is_diagnostics_events_enabled = bool
    is_health_monitoring_enabled  = bool
    is_incident_logs_enabled      = bool
  })
  default = {
    is_diagnostics_events_enabled = true
    is_health_monitoring_enabled  = true
    is_incident_logs_enabled      = true
  }
}

