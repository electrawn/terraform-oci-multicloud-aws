variable "exainfra_id" {
  description = "AWS ExaData infra ID for Oracle DB (AWS ID)"
  type        = string
}

variable "vm_cluster_id" {
  description = "AWS VM Cluster ID for Oracle DB (AWS ID)"
  type        = string
}

variable "environment" {
  description = "Variable for environment (dev/prd)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region the dashboards render metrics from"
  type        = string
  default     = "us-east-1"
}

variable "dashboard_name_prefix" {
  description = "Prefix for the dashboard name. Defaults to the VM cluster name."
  type        = string
  default     = ""
}
