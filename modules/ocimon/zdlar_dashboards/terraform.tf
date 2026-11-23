# oracle/oci is needed for the OCI Management Dashboard service.
terraform {
  required_providers {
    oci = { source = "oracle/oci" }
  }
}
