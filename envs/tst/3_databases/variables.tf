variable "environment" {
  description = "Environment"
  type        = string
  default     = "tst"
}

variable "exainfra_id" {
  description = "AWS ExaData infra ID for Oracle DB (AWS ID). When null, resolved from 2_compute remote state."
  type        = string
  default     = null
}
variable "exainfra_ocid" {
  description = "OCI ExaData infra OCID. When null, resolved from 2_compute remote state."
  type        = string
  default     = null
}
variable "vm_cluster_id" {
  description = "AWS VM Cluster ID for Oracle DB (AWS ID). When null, resolved from 2_compute remote state."
  type        = string
  default     = null
}
variable "vm_cluster_name" {
  description = "AWS VM Cluster Name. When null, resolved from 2_compute remote state."
  type        = string
  default     = null
}
variable "vm_cluster_ocid" {
  description = "OCI VM Cluster OCID. When null, resolved from 2_compute remote state."
  type        = string
  default     = null
}


# ==================================Database Home vars==========================
variable "db_home_source" {
  type        = string
  description = "The source of database. VM_CLUSTER_NEW for creating a database for VM Cluster."
  default     = "VM_CLUSTER_NEW"
}

variable "db_home_name" {
  type        = string
  description = "Name of DB Home"
  default     = "test-dbh19"
}

variable "db_home_version" {
  type        = string
  description = "The Oracle Database version"
  default     = "19.23.0.0.0"
}

# ==================================Container Database vars==========================
variable "cdb_name" {
  type        = string
  description = "The display name of the database. (required)"
  default     = "tstcdb"
}

variable "cdb_admin_password" {
  type        = string
  sensitive   = true
  description = "A strong password for SYS, SYSTEM, PDB Admin and TDE Wallet. (required)"
  default     = null # supply via TF_VAR_* or a secrets manager
}

variable "cdb_source" {
  type        = string
  default     = "NONE"
  description = "The source of the database (optional), default NONE."
}

variable "cdb_auto_backup_enabled" {
  type        = bool
  default     = false
  description = "Enable automatic backup (optional), default false"
}

# ==================================Pluggable Database vars==========================
variable "pdb_name" {
  type    = string
  default = "Name of the Pluggable Database"
}
variable "pdb_admin_password" {
  type      = string
  sensitive = true
  default   = null # supply via TF_VAR_* or a secrets manager
}
variable "pdb_tde_wallet_password" {
  type      = string
  sensitive = true
  default   = null # supply via TF_VAR_* or a secrets manager
}
