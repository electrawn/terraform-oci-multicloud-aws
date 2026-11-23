# Name of the S3 bucket for Terraform remote state
variable "bucket_name" {
  description = "S3 bucket to store Terraform state"
  type        = string
  default     = "example-iac-terraform-state-prd"
}

# AWS CLI profile
variable "profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
  default     = "example-admin-profile"
}

variable "tags" {
  type = map(string)
  default = {
    created_by  = "terraform"
    Team        = "Database Team"
    Environment = "prd"
  }
}

# Tags
variable "environment" {
  description = "Environment name (e.g., dev, stage, prod)"
  type        = string
  default     = "prd"
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

# iac_admin user OCID
variable "iac_admin_user_ocid" {
  description = "OCID of the iac_admin service user"
  type        = string
  default     = "ocid1.user.oc1..exampleuniqueiduser0002"
}

# Default OCI resource anchor compartment (cannot delete resources here)
variable "oci_resource_anchor_compartment_ocid" {
  description = "OCID of the 111111111111_default-oci-resource-anchor compartment"
  type        = string
  default     = "ocid1.compartment.oc1..exampleuniqueidcompar0001"
}

# Parent compartment for monitor/infra child compartments (MulticloudLink — parent of 609 anchor)
variable "parent_compartment_ocid" {
  description = "OCID of the parent compartment for monitoring child compartments"
  type        = string
  default     = "ocid1.compartment.oc1..exampleuniqueidcompar0002"
}


