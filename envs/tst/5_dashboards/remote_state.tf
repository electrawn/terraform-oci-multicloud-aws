# ---------------------------------------------------------------------------
# Remote state reference: 2_compute
# Provides compute cluster IDs consumed by 5_dashboards modules
# ---------------------------------------------------------------------------
data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket = "example-iac-terraform-state-tst"
    key    = "tst/2_compute/terraform.tfstate"
    region = "us-east-1"
  }
}


# ---------------------------------------------------------------------------
# Remote state reference: 0_bootstrap
# Provides monitor_compartment_ocid for OCI-side dashboard placement.
# ---------------------------------------------------------------------------
data "terraform_remote_state" "bootstrap" {
  backend = "s3"
  config = {
    bucket = "example-iac-terraform-state-tst"
    key    = "tst/0_bootstrap/terraform.tfstate"
    region = "us-east-1"
  }
}

# ---------------------------------------------------------------------------
# Remote state reference: 3_databases
# Provides the cdbs / pdbs maps (name + OCID) consumed by the OCI-side
# management dashboards, which key metric queries on the database OCID.
# ---------------------------------------------------------------------------
data "terraform_remote_state" "databases" {
  backend = "s3"
  config = {
    bucket = "example-iac-terraform-state-tst"
    key    = "tst/3_databases/terraform.tfstate"
    region = "us-east-1"
  }
}
