terraform {
  backend "s3" {
    bucket       = "example-iac-terraform-state-tst" # <-- change
    key          = "tst/terraform.tfstate"
    region       = "us-east-1" # <-- change
    use_lockfile = true
    encrypt      = true
  }
  required_version = ">= 1.14.0"
}


