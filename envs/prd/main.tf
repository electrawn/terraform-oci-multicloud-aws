# ===========================================================================
# REFACTORED: Multistage Terraform Pipeline - prd
# ===========================================================================
#
# Each numbered subdirectory is now an independent Terraform root with its
# own state file in S3.  Run stages IN ORDER; later stages read earlier
# stage outputs via terraform_remote_state.
#
# IMPORTANT: Set $env:AWS_PROFILE = "terraform-auth" before running any stage.
#
# State keys (bucket: example-iac-terraform-state-prd):
#   prd/0_bootstrap/terraform.tfstate
#   prd/1_network/terraform.tfstate
#   prd/2_compute/terraform.tfstate
#   prd/3_databases/terraform.tfstate
#   prd/4_monitoring/terraform.tfstate   <- dedicated monitoring stage (phase 1)
#
# Stage dependency chain:
#   0_bootstrap  (no deps)
#       1_network  (no deps from 0_bootstrap at runtime)
#          2_compute  <- reads 1_network remote state (aws_odb_network_resource_id)
#             3_databases  <- reads 2_compute remote state (exa1/exa2/exa3 cluster IDs)
#                4_monitoring  <- reads 2_compute + 3_databases remote state
#
# 2_compute orchestrates: exa1/, exa2/, exa3/ sub-modules in a single state
# 3_databases orchestrates: exa1/, exa2/, exa3/ sub-modules in a single state
#
# To run a stage (example for 3_databases):
#   cd 3_databases
#   terraform init
#   terraform plan
#   terraform apply
#
# Apply safety rule: NEVER auto-chain applies in production.
# Always stop after a single apply and await human confirmation.
#
# ===========================================================================