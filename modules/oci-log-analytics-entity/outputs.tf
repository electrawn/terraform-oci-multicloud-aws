output "id" {
  description = "The OCID of the log analytics entity."
  value       = oci_log_analytics_log_analytics_entity.this.id
}

output "resource" {
  description = "The full resource object of the log analytics entity."
  value       = oci_log_analytics_log_analytics_entity.this
}

output "state" {
  description = "The current state of the log analytics entity."
  value       = oci_log_analytics_log_analytics_entity.this.state
}
