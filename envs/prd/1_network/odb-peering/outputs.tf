output "odb_peering_id" {
  value = try(module.odb_peering[0].peering_id, null)
}

output "odb_peering_resource" {
  value = try(module.odb_peering[0], null)
}