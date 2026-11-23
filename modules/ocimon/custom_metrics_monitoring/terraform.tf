# Provider requirements.
# - oracle/oci   : OCI Monitoring alarms
# - hashicorp/aws: aws_odb_db_nodes data source (DB node discovery)
terraform {
  required_providers {
    oci = { source = "oracle/oci" }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.15.0"
    }
  }
}
