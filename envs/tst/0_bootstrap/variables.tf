# Name of the S3 bucket for Terraform remote state
variable "bucket_name" {
  description = "S3 bucket to store Terraform state"
  type        = string
  default     = "example-iac-terraform-state-tst"
}

# AWS CLI profile
variable "profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
  default     = "example-admin-profile"
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Tags
variable "environment" {
  description = "Environment name (e.g., tst, stage, prod)"
  type        = string
  default     = "tst"
}



# OCI provider variables
variable "oci_region" {
  default = "us-ashburn-1"
}
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

# Parent compartment for tst child compartments (MulticloudLink — parent of 609 anchor)
variable "parent_compartment_ocid" {
  description = "OCID of the parent compartment for monitoring child compartments"
  type        = string
  default     = "ocid1.compartment.oc1..exampleuniqueidcompar0002"
}
