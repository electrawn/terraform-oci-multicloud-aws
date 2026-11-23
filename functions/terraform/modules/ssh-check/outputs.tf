# Outputs from ssh-check module

output "function_ocid" {
  description = "OCID of the ssh-check function"
  value       = oci_functions_function.ssh_check.id
}

output "function_display_name" {
  description = "Display name of the ssh-check function"
  value       = oci_functions_function.ssh_check.display_name
}

output "function_invoke_endpoint" {
  description = "HTTPS endpoint URL for invoking the ssh-check function"
  value       = oci_functions_function.ssh_check.invoke_endpoint
}

output "metric_namespace" {
  description = "OCI Monitoring namespace for emitted metrics"
  value       = "example_oracledb_aws"
}

output "metric_name" {
  description = "OCI Monitoring metric name emitted by this function"
  value       = "sshstatus"
}

