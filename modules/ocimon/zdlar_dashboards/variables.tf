variable "compartment_ocid" {
  description = "OCID of the compartment where the management dashboard and saved searches are created."
  type        = string
}

variable "vm_cluster_name" {
  description = "VM cluster name, used for dashboard naming (e.g. exa1vmc1)."
  type        = string
}

variable "environment" {
  description = "Environment (sbx/dev/prd). Used in the dashboard display name."
  type        = string
  default     = "sbx"
}

variable "region" {
  description = "OCI region the recovery-service metrics are emitted in (metric query region)."
  type        = string
  default     = "us-ashburn-1"
}

# ---------------------------------------------------------------------------
# Protected databases to chart, keyed by DB name. Each value is the PROTECTED
# DATABASE resource OCID (ocid1.recoveryserviceprotecteddatabase...) — the
# resourceId the oci_recovery_service metrics key on. Get it from the Recovery
# Service "protected databases" list, or:
#   oci recovery protected-database-collection list-protected-databases \
#     --compartment-id <infra compartment> --region <region> --all
#
# One dashboard is produced per entry, ready to roll out to every CDB as they
# onboard to the ZDLAR service.
# ---------------------------------------------------------------------------
variable "protected_databases" {
  description = "Map of DB name => protected-database resource OCID to build ZDLAR dashboards for."
  type        = map(string)
}

variable "dashboard_name_prefix" {
  description = "Prefix for each dashboard display name. Defaults to \"<vm_cluster_name>-ZDLAR\"."
  type        = string
  default     = ""
}
