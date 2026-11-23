terraform {
  required_version = ">= 1.9.0"

  required_providers {
    oci = {
      source = "oracle/oci"
      # oci_resource_scheduler_schedule needs >= 6.2
      version = ">= 6.2"
    }
  }
}

# Authentication: use an OCI config profile or the OCI_* environment variables.
# No credentials are stored in this repository.
provider "oci" {
  region = var.region
}
