output "peering_id" {
  description = "ID of the ODB network peering connection"
  value       = aws_odb_network_peering_connection.this.id
}
