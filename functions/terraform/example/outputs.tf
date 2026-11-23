output "application_ocid" {
  description = "OCID of the Functions application"
  value       = oci_functions_application.this.id
}

output "ssh_check_function_ocids" {
  description = "Function OCIDs by cluster key"
  value       = { for k, m in module.ssh_check : k => m.function_ocid }
}

output "metric_namespace" {
  description = "Namespace the functions publish to. Point your alarms at it."
  value       = length(module.ssh_check) > 0 ? values(module.ssh_check)[0].metric_namespace : null
}
