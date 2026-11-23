# ---------------------------------------------------------------------------
# Remote state reference: 1_network
# Provides: aws_odb_network_resource_id (used as vmc_odb_network_id)
# ---------------------------------------------------------------------------
# NOTE: tst currently hardcodes vmc_odb_network_id = "odbnet_example0001"
# Use the data source below when switching to dynamic network ID wiring.
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "example-iac-terraform-state-tst"
    key    = "tst/1_network/terraform.tfstate"
    region = "us-east-1"
  }
}

