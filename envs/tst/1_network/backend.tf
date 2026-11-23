terraform {
  backend "s3" {
    bucket       = "example-iac-terraform-state-tst"
    key          = "tst/1_network/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
  required_version = ">= 1.14.0"
}

