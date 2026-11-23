# ---------------------------------------------------------------------------
# Remote state reference: 2_compute
# Provides exa1/exa2/exa3 compute cluster IDs for 3_databases modules
# ---------------------------------------------------------------------------
data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket = "example-iac-terraform-state-prd"
    key    = "prd/2_compute/terraform.tfstate"
    region = "us-east-1"
  }
}

