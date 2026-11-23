
output "cloud_exadata_infrastructure_id" {
  description = "Exadata Infra ID (for ODB@AWS)"
  value       = aws_odb_cloud_exadata_infrastructure.this.id
}

output "compute_count" {
  description = "Number of database servers for this Exadata infrastructure"
  value       = aws_odb_cloud_exadata_infrastructure.this.compute_count
}

output "db_server_ids" {
  description = "Sorted DB server IDs under this Exadata"
  value       = sort([for s in data.aws_odb_db_servers.this.db_servers : s.id])
}

