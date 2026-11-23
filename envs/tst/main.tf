# ===========================================================================
# REFACTORED: Multistage Terraform Pipeline - tst
# ===========================================================================
#
# Each numbered subdirectory is now an independent Terraform root with its
# own state file in S3.  Run stages IN ORDER; later stages read earlier
# stage outputs via terraform_remote_state.
#
# State keys (bucket: example-iac-terraform-state-tst):
#   tst/0_bootstrap/terraform.tfstate
#   tst/1_network/terraform.tfstate
#   tst/2_compute/terraform.tfstate
#   tst/3_databases/terraform.tfstate
#   tst/4_monitoring/terraform.tfstate   <- monitoring resources (ACTIVE)
#   tst/5_dashboards/terraform.tfstate
#
# Stage dependency chain:
#   0_bootstrap  (no deps)
#       1_network  (no deps from 0_bootstrap at runtime)
#          2_compute  <- reads 1_network remote state
#             3_databases  <- reads 2_compute remote state
#                4_monitoring  <- reads 2_compute + 3_databases remote state
#             5_dashboards  <- reads 2_compute remote state
#
# To run a stage (example for 2_compute):
#   cd 2_compute
#   terraform init
#   terraform plan
#   terraform apply
#
# ===========================================================================