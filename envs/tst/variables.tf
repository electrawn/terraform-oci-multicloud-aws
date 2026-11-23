#==================================AWS common vars==========================
variable "aws_region" {
  description = "AWS Region, e.g. us-west-2"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "tst"
}

#==================================OCI common vars==========================
variable "oci_region" {
  description = "OCI Region, e.g. us-phoenix-1"
  type        = string
  default     = "us-ashburn-1"
}

# OCI Authentication
variable "oci_auth" {
  type        = string
  description = "OCI Authentication method, default: APIKey, InstancePrincipal | ResourcePrincipal | SecurityToken"
  default     = "APIKey"
}
variable "oci_config_file_profile" {
  type        = string
  description = "OCI Config file name"
  default     = "DEFAULT"
}

variable "oci_tenancy_ocid" {
  type        = string
  description = "OCID of the OCI tenancy"
  default     = "ocid1.tenancy.oc1..exampleuniqueidtenanc0001"
}

variable "oci_user_ocid" {
  type        = string
  description = "OCID of the OCI user"
  default     = null
}
variable "oci_private_key_path" {
  type        = string
  description = "The path (including filename) of the private key"
  default     = null
}
variable "oci_private_key_password" {
  type        = string
  description = "Passphrase used for the key, if it's encrypted"
  sensitive   = true
  default     = null
}
variable "oci_fingerprint" {
  type        = string
  description = "Fingerprint for the key pair being used"
  default     = null
}

variable "opsgenie_api_key" {
  default = "1e3b667b-b64b-4b6d-b228-50b4035622a8"
}

variable "opsgenie_alert_arn" {
  default = "arn:aws:sns:us-east-1:222222222222:EventBrokerSNS-prd"
}

variable "opsgenie_notifications_topic" {
  default = "ocid1.onstopic.oc1.iad.exampleuniqueidonstop0001"
}