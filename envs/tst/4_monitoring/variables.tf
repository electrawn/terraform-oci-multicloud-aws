variable "environment" {
  description = "Environment name"
  type        = string
  default     = "tst"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "oci_region" {
  description = "OCI region"
  type        = string
  default     = "us-ashburn-1"
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform remote state"
  type        = string
  default     = "example-iac-terraform-state-tst"
}

variable "opsgenie_alert_arn" {
  description = "ARN of the SNS topic for Opsgenie alerts"
  type        = string
  default     = "arn:aws:sns:us-east-1:222222222222:EventBrokerSNS-prd"
}

variable "notification_topic_ocid" {
  description = "OCI ONS topic OCID for alarm destinations"
  type        = string
  default     = "ocid1.onstopic.oc1.iad.exampleuniqueidonstop0002"
}

variable "in_downtime" {
  description = "Whether the environment is in downtime (disables alarm actions)"
  type        = bool
  default     = false
}

variable "support_category" {
  description = "Support category for OpsGenie alarms"
  type        = string
  default     = "Database"
}

variable "support_teams" {
  description = "Support team (call queue) for OpsGenie alarms"
  type        = string
  default     = "EXAMPLE_ONCALL_TEAM"
}

variable "tag_team" {
  description = "AWS tag resource Team Name"
  type        = string
  default     = "Database Team"
}

variable "tag_created_by" {
  description = "AWS tag resource Created By"
  type        = string
  default     = "Database"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default = {
    "created_by" = "Terraform"
    "Team"       = "Database Team"
  }
}

# OCI provider configuration variables
variable "oci_tenancy_ocid" {
  default = "ocid1.tenancy.oc1..exampleuniqueidtenanc0001"
}
variable "oci_user_ocid" {
  default = null
}
variable "oci_fingerprint" {
  default = null
}
variable "oci_private_key_path" {
  default = null
}

# ========================================
# Log Analytics variables
# ========================================
variable "log_analytics_namespace" {
  description = "OCI Log Analytics namespace (tenancy namespace). Obtain via 'oci os ns get'."
  type        = string
  default     = "idbazu9icynp"
}

variable "enable_log_analytics" {
  description = "Enable log analytics entity creation. Set to true once namespace is confirmed and IAM policies are in place."
  type        = bool
  default     = true
}


# ---------------------------------------------------------------------------
# Custom-namespace alarms (example_oracledb_aws) for the oci-functions metrics.
# ---------------------------------------------------------------------------
variable "enable_custom_metric_alarms" {
  description = "Master switch for the custom_metrics_monitoring alarms (libcache, sshstatus, oracle_service_status). Enabled: TST checks are healthy (ocimon on PDB501 via ocimon_credential_devprd; ssh-check targets the admin network)."
  type        = bool
  default     = true
}

variable "oracle_service_databases" {
  description = "database_name dimension values to create oracle_service_status alarms for. Must match the dimension oracle-service-check emits: the connect SERVICE name, not the PDB name."
  type        = list(string)
  default     = ["cdb005_pdb520.paas.oracle.com"]
}

variable "libcache_warning_threshold" {
  description = "libcache_waiting_sessions (rolling 4h ASH sample count) above which the WARNING (P4) alarm fires, per RAC instance."
  type        = number
  default     = 3
}

variable "libcache_critical_threshold" {
  description = "libcache_waiting_sessions (rolling 4h ASH sample count) above which the CRITICAL (P3) alarm fires, per RAC instance."
  type        = number
  default     = 50
}
