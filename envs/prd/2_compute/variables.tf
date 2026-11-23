variable "environment" {
  type    = string
  default = "prd"
}

variable "opsgenie_alert_arn" {
  type    = string
  default = "arn:aws:sns:us-east-1:222222222222:EventBrokerSNS-prd"
}

variable "enable_inline_monitoring" {
  description = "Keep CloudWatch monitoring modules in 2_compute/exa{1,2,3} during phased migration"
  type        = bool
  default     = false
}

variable "compute_exa3_is_enabled_vm_cluster_cpu" {
  description = "Enable DB server CPU utilization CloudWatch alarms for exa3 only"
  type        = bool
  default     = true
}

# ---- exa1 ----
variable "exa1_exadata_infrastructure_name" {
  type    = string
  default = "exa1"
}
variable "exa1_exadata_infrastructure_compute_count" {
  type    = number
  default = 4
}
variable "exa1_exadata_infrastructure_storage_count" {
  type    = number
  default = 4
}
variable "exa1_vmc_vm_cluster_name" {
  type    = string
  default = "exa1vmc1"
}
variable "exa1_vmc_gi_cluster_name" {
  type    = string
  default = "exa1vmc1"
}
variable "exa1_vmc_cpu_core_count_per_vm" {
  type    = number
  default = 56
}
variable "exa1_vmc_hostname_prefix" {
  type    = string
  default = "exa1vmc1"
}
variable "exa1_vmc_data_storage_size_in_tbs" {
  type    = number
  default = 240
}
variable "exa1_vmc_db_node_storage_size_in_gbs_per_vm" {
  type    = number
  default = 900
}
variable "exa1_vmc_memory_size_in_gbs_per_vm" {
  type    = number
  default = 1390
}
variable "exa1_vmc_vm_ssh_public_keys" {
  type = set(string)
  default = [
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@example.com",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal"
  ]
}

# ---- exa2 ----
variable "exa2_exadata_infrastructure_name" {
  type    = string
  default = "exa2"
}
variable "exa2_exadata_infrastructure_compute_count" {
  type    = number
  default = 4
}
variable "exa2_exadata_infrastructure_storage_count" {
  type    = number
  default = 8
}
variable "exa2_vmc_vm_cluster_name" {
  type    = string
  default = "exa2vmc1"
}
variable "exa2_vmc_gi_cluster_name" {
  type    = string
  default = "exa2vmc1"
}
variable "exa2_vmc_cpu_core_count_per_vm" {
  type    = number
  default = 44
}
variable "exa2_vmc_hostname_prefix" {
  type    = string
  default = "exa2vmc1"
}
variable "exa2_vmc_data_storage_size_in_tbs" {
  type    = number
  default = 640
}
variable "exa2_vmc_db_node_storage_size_in_gbs_per_vm" {
  type    = number
  default = 900
}
variable "exa2_vmc_memory_size_in_gbs_per_vm" {
  type    = number
  default = 1390
}
variable "exa2_vmc_vm_ssh_public_keys" {
  type = set(string)
  default = [
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@example.com",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal"
  ]
}

# ---- exa3 ----
variable "exa3_exadata_infrastructure_name" {
  type    = string
  default = "exa3"
}
variable "exa3_exadata_infrastructure_compute_count" {
  type    = number
  default = 2
}
variable "exa3_exadata_infrastructure_storage_count" {
  type    = number
  default = 3
}
variable "exa3_vmc_vm_cluster_name" {
  type    = string
  default = "exa3vmc1"
}
variable "exa3_vmc_gi_cluster_name" {
  type    = string
  default = "exa3vmc1"
}
variable "exa3_vmc_cpu_core_count_per_vm" {
  type    = number
  default = 8
}
variable "exa3_vmc_hostname_prefix" {
  type    = string
  default = "exa3vmc1"
}
variable "exa3_vmc_data_storage_size_in_tbs" {
  type    = number
  default = 240
}
variable "exa3_vmc_db_node_storage_size_in_gbs_per_vm" {
  type    = number
  default = 900
}
variable "exa3_vmc_memory_size_in_gbs_per_vm" {
  type    = number
  default = 1390
}
variable "exa3_vmc_vm_ssh_public_keys" {
  type = set(string)
  default = [
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@example.com",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal",
    "ssh-rsa AAAAB3NzaC1yc2E-REPLACE-WITH-YOUR-PUBLIC-KEY user@dbnode.example.internal"
  ]
}

