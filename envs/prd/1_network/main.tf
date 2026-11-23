module "network_odb" {
  source                               = "./odb"
  aws_odb_network_availability_zone_id = var.aws_odb_network_availability_zone_id
  aws_odb_network_display_name         = var.aws_odb_network_display_name
  aws_odb_network_client_subnet_cidr   = var.aws_odb_network_client_subnet_cidr
  aws_odb_network_backup_subnet_cidr   = var.aws_odb_network_backup_subnet_cidr
  aws_odb_network_custom_domain_name   = var.aws_odb_network_custom_domain_name
  aws_odb_network_default_dns_prefix   = var.aws_odb_network_default_dns_prefix
  aws_odb_network_s3_access            = var.aws_odb_network_s3_access
  aws_odb_network_zero_etl_access      = var.aws_odb_network_zero_etl_access
  aws_odb_network_s3_policy_document   = var.aws_odb_network_s3_policy_document
  odb_network_tags                     = var.tags
}

module "network_odb_peering" {
  source               = "./odb-peering"
  peering_display_name = var.peering_display_name
  #TODO: Fix this so dependent on other module
  #peering_odb_network_id = module.network_odb.aws_odb_network_oci_vcn_id
  peering_odb_network_id = var.peering_odb_network_id
  peering_network_id     = var.peering_network_id
  peering_tags           = var.tags
}

output "aws_odb_network_resource_id" {
  description = "Resource ID of ODB network in AWS"
  value       = module.network_odb.aws_odb_network_resource_id
}

output "aws_odb_network_resource" {
  description = "AWS ODB network resource"
  value       = module.network_odb.aws_odb_network_resource
}

output "aws_odb_network_oci_vcn_id" {
  description = "AWS ODB network OCI VCN ID"
  value       = module.network_odb.aws_odb_network_oci_vcn_id
}

output "aws_odb_network_managed_services" {
  description = "AWS ODB network managed services"
  value       = module.network_odb.aws_odb_network_managed_services
}

output "odb_peering_id" {
  value = module.network_odb_peering.odb_peering_id
}

output "odb_peering_resource" {
  value = module.network_odb_peering.odb_peering_resource
}