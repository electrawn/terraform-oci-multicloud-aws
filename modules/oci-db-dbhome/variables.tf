variable "vm_cluster_ocid" {
  description = "The OCID of the VM cluster"
  type        = string
}

variable "db_system_ocid" {
  description = "The OCID of the DB System"
  type        = string
  default     = null
}

variable "db_home_version" {
  description = "The DB home version"
  type        = string
}

variable "db_home_name" {
  description = "The DB home name"
  type        = string
}

variable "db_home_source" {
  description = "The source of DB home. e.g. VM_CLUSTER_NEW"
  type        = string
}

variable "database_software_image_id" {
  description = "OCID of DBHome image"
  type        = string
  default     = null
}

variable "is_desupported_version" {
  description = "Set to True to use older database versions"
  type        = bool
  default     = null
}