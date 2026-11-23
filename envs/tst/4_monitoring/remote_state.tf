# ---------------------------------------------------------------------------
# Remote state references for 4_monitoring stage
# Monitoring resources will consume outputs from 0_bootstrap, 2_compute, and 3_databases.
# ---------------------------------------------------------------------------
data "terraform_remote_state" "bootstrap" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "${var.environment}/0_bootstrap/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "${var.environment}/2_compute/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "databases" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "${var.environment}/3_databases/terraform.tfstate"
    region = var.aws_region
  }
}

