terraform {
  backend "s3" {
    bucket       = "example-iac-terraform-state-prd"
    key          = "prd/1_network/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
  required_version = ">= 1.13.0"
}

