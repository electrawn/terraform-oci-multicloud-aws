terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.31.0" # ODB resources introduced here
    }
    # https://registry.terraform.io/providers/oracle/oci/latest/docs
    oci = {
      source = "oracle/oci"
    }
    # https://registry.terraform.io/providers/hashicorp/local/latest/docs
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # Authentication is provided via the AWS_PROFILE environment variable.
  # Set $env:AWS_PROFILE = "terraform-auth" in PowerShell before running terraform.
}

# https://docs.oracle.com/en-us/iaas/Content/dev/terraform/configuring.htm#authentication
provider "oci" {
  region       = var.oci_region
  tenancy_ocid = var.oci_tenancy_ocid
  #  config_file_profile  = var.oci_config_file_profile
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key_path
}