# ---------------------------------------------------------------------------
# Remote state reference: 1_network
# Provides aws_odb_network_resource_id consumed by all exa VM clusters
# ---------------------------------------------------------------------------
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "example-iac-terraform-state-prd"
    key    = "prd/1_network/terraform.tfstate"
    region = "us-east-1"
  }
}

