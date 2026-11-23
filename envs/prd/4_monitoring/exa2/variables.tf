variable "enable_monitoring_stage" {
  type = bool
}

variable "environment" {
  type = string
}

variable "opsgenie_alert_arn" {
  type = string
}

variable "in_downtime" {
  type = bool
}

variable "support_category" {
  type = string
}

variable "support_teams" {
  type = string
}

variable "exainfra_id" {
  type = string
}

variable "exainfra_ocid" {
  type = string
}

variable "exainfra_name" {
  type = string
}

variable "vm_cluster_id" {
  type = string
}

variable "vm_cluster_name" {
  type = string
}

variable "vm_cluster_ocid" {
  type = string
}

variable "db_servers" {
  type = any
}

variable "db_nodes" {
  type = any
}

