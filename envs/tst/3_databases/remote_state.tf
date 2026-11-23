# ---------------------------------------------------------------------------
# Remote state reference: 2_compute
# Provides compute outputs consumed by 3_databases modules
# ---------------------------------------------------------------------------
data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket = "example-iac-terraform-state-tst"
    key    = "tst/2_compute/terraform.tfstate"
    region = "us-east-1"
  }
}

