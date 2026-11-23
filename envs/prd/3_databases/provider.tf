terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.31.0"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 8.25.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # Set AWS_PROFILE=terraform-auth before running
}

provider "oci" {
  region           = var.oci_region
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key_path
}

variable "aws_region" {
  default = "us-east-1"
}
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

