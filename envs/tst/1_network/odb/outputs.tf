output "aws_odb_network_resource_id" {
  description = "Resource ID of ODB network in AWS"
  value       = try(module.odb_network.aws_odb_network_resource_id, null)
}

output "aws_odb_network_resource" {
  description = "AWS ODB network resource"
  value       = try(module.odb_network.aws_odb_network_resource, null)
}

output "aws_odb_network_oci_vcn_id" {
  description = "AWS ODB network OCI VCN ID"
  value       = try(module.odb_network.aws_odb_network_oci_vcn_id, null)
}

output "aws_odb_network_managed_services" {
  description = "AWS ODB network managed services"
  value       = try(module.odb_network.aws_odb_network_managed_services, null)
}