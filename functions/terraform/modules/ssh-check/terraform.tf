# Pin the OCI provider to the Oracle namespace (oracle/oci). Without this,
# Terraform defaults an undeclared `oci` provider to hashicorp/oci, which
# conflicts with the oracle/oci the environments require.
terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}
