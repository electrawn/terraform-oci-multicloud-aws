variable "environment" {
  description = "Environment"
  type        = string
  default     = "prd"
}
variable "private_end_point_ocid" {
  description = "OCI DB Management private endpoint OCID"
  type        = string
  default     = "ocid1.dbmgmtprivateendpoint.oc1.iad.exampleuniqueiddbmgmt0002"
}
# Legacy interface vars (passed through to exa sub-modules)
variable "db_home_name" {
  type    = string
  default = "dbhome-Apphome1"
}
variable "db_home_version" {
  type    = string
  default = "19.23.0.0"
}
variable "cdb_name" {
  type    = string
  default = "tstcdb"
}
variable "cdb_admin_password" {
  type      = string
  sensitive = true
  default   = null # supply via TF_VAR_* or a secrets manager
}
variable "cdb_source" {
  type    = string
  default = "NONE"
}
variable "pdb_name" {
  type    = string
  default = "tstpdb"
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
# ---------------------------------------------------------------------------
# Optional overrides: when null, values come from 2_compute remote state
# ---------------------------------------------------------------------------
# exa1
variable "exa1_exainfra_id" {
  type    = string
  default = null
}
variable "exa1_exainfra_ocid" {
  type    = string
  default = null
}
variable "exa1_vm_cluster_id" {
  type    = string
  default = null
}
variable "exa1_vm_cluster_name" {
  type    = string
  default = null
}
variable "exa1_vm_cluster_ocid" {
  type    = string
  default = null
}
# exa2
variable "exa2_exainfra_id" {
  type    = string
  default = null
}
variable "exa2_exainfra_ocid" {
  type    = string
  default = null
}
variable "exa2_vm_cluster_id" {
  type    = string
  default = null
}
variable "exa2_vm_cluster_name" {
  type    = string
  default = null
}
variable "exa2_vm_cluster_ocid" {
  type    = string
  default = null
}
# exa3
variable "exa3_exainfra_id" {
  type    = string
  default = null
}
variable "exa3_exainfra_ocid" {
  type    = string
  default = null
}
variable "exa3_vm_cluster_id" {
  type    = string
  default = null
}
variable "exa3_vm_cluster_name" {
  type    = string
  default = null
}
variable "exa3_vm_cluster_ocid" {
  type    = string
  default = null
}