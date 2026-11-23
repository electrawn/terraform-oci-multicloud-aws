provider "aws" {
  region = "us-east-1"
}

provider "oci" {
  region           = var.oci_region
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key_path
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.44.0"
    }
    oci = {
      source = "oracle/oci"
    }
  }
}