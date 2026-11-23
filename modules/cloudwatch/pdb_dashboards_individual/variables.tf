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

variable "databases" {
  description = "List of PDB database names. One dashboard is created per database."
  type        = list(string)
}

variable "environment" {
  description = "Variable for environment (dev/prd)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region the metrics/dashboards live in"
  type        = string
  default     = "us-east-1"
}

variable "dashboard_name_prefix" {
  description = "Prefix for each dashboard name. Defaults to \"<vm_cluster_name>-PDB\". The database name is appended per dashboard."
  type        = string
  default     = ""
}
