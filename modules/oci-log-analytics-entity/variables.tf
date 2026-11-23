variable "namespace" {
  description = "The Log Analytics namespace (typically the tenancy name). Obtain via 'oci os ns get'."
  type        = string
}

variable "compartment_id" {
  description = "Compartment OCID where the log analytics entity will be created."
  type        = string
}

variable "name" {
  description = "Display name for the log analytics entity."
  type        = string
}

variable "entity_type_name" {
  description = "Log analytics entity type name (e.g., 'Oracle Database Instance' for RAC nodes)."
  type        = string
  default     = "Oracle Database Instance"
}

variable "hostname" {
  description = "The hostname of the DB node where this entity resides."
  type        = string
  default     = null
}

variable "cloud_resource_id" {
  description = "The OCID of the cloud resource this entity represents (e.g., database OCID)."
  type        = string
  default     = null
}

variable "management_agent_id" {
  description = "The OCID of the Management Agent associated with this entity."
  type        = string
  default     = null
}

variable "timezone_region" {
  description = "The timezone region of the log analytics entity."
  type        = string
  default     = null
}

variable "properties" {
  description = "Name/value pairs for parameter values used in file patterns specified in log sources."
  type        = map(string)
  default     = {}
}

variable "metadata_items" {
  description = "List of metadata items for the entity."
  type = list(object({
    name  = string
    type  = optional(string)
    value = string
  }))
  default = []
}

variable "freeform_tags" {
  description = "Simple key-value pair tags."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags for this resource."
  type        = map(string)
  default     = {}
}

variable "source_associations" {
  description = "List of log source associations for this entity. Each entry links a source to a log group."
  type = list(object({
    source_name    = string
    log_group_id   = string
    compartment_id = string
  }))
  default = []
}
