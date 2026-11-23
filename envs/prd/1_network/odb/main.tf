# ------------------------
# ODB / OCI / ODB Network
# ------------------------
module "odb_network" {
  source                                 = "../../../../modules/aws-odb-network"
  aws_odb_network_availability_zone_id   = var.aws_odb_network_availability_zone_id
  aws_odb_network_display_name           = var.aws_odb_network_display_name
  aws_odb_network_client_subnet_cidr     = var.aws_odb_network_client_subnet_cidr
  aws_odb_network_backup_subnet_cidr     = var.aws_odb_network_backup_subnet_cidr
  aws_odb_network_custom_domain_name     = var.aws_odb_network_custom_domain_name
  aws_odb_network_default_dns_prefix     = var.aws_odb_network_default_dns_prefix
  aws_odb_network_s3_access              = var.aws_odb_network_s3_access
  aws_odb_network_zero_etl_access        = var.aws_odb_network_zero_etl_access
  aws_odb_network_s3_policy_document     = var.aws_odb_network_s3_policy_document
  aws_odb_network_sts_access             = var.aws_odb_network_sts_access
  aws_odb_network_kms_access             = var.aws_odb_network_kms_access
  aws_odb_network_sts_document           = var.aws_odb_network_sts_document
  aws_odb_network_kms_document           = var.aws_odb_network_kms_document
  delete_odb_network_associated_resource = var.delete_odb_network_associated_resource
  tags                                   = var.odb_network_tags
}
