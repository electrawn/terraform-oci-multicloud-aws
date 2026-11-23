# SSH Check Function Module
#
# Deploys the ssh-check OCI Function which monitors SSH connectivity to Exadata nodes.
# The function queries OCI Database Service for all active Cloud VM Cluster DB nodes
# and performs TCP/SSH banner checks, publishing per-node status as custom metrics.
#
# Metric: example_oracledb_aws:sshstatus
# Values: 0 = OK (node responds to SSH), 1 = FAILED (node unreachable or no SSH banner)

resource "oci_functions_function" "ssh_check" {
  application_id     = var.application_ocid
  display_name       = "ssh-check-${var.env}${var.name_suffix}"
  memory_in_mbs      = var.function_memory_in_mbs
  timeout_in_seconds = var.function_timeout_in_seconds

  source_details {
    image       = var.function_image
    source_type = "CONTAINER_IMAGE"
  }

  config = {
    OCI_REGION = var.region
    # Compartment the function queries for Exadata VM clusters / DB nodes.
    # Defaults to compartment_ocid, but can point at the compartment where the
    # cluster actually lives (which may differ from the function's compartment).
    OCI_COMPARTMENT_ID = var.discovery_compartment_ocid != "" ? var.discovery_compartment_ocid : var.compartment_ocid
    # Compartment the sshstatus metric is PUBLISHED to: the function's own
    # (monitor) compartment, where the other ocidb-monitoring metrics and the
    # custom_metrics_monitoring alarms live. Without this, metrics landed in
    # the discovery (DB) compartment and the alarms never saw them.
    METRIC_COMPARTMENT_ID = var.compartment_ocid
    SSH_CHECK_PORT        = tostring(var.ssh_check_port)
    SSH_CHECK_TIMEOUT     = tostring(var.ssh_check_timeout_seconds)
    # sshd listens on the admin network, so probe <hostname>.<SSH_CHECK_DOMAIN>
    # (target 'admin'), not the client IP/VIP.
    SSH_CHECK_TARGET = var.ssh_check_target
    SSH_CHECK_DOMAIN = var.ssh_check_domain
    # Optional: restrict the check to a single VM cluster (by display name).
    SSH_CHECK_VM_CLUSTER_NAME = var.vm_cluster_name
    LOG_LEVEL                 = var.log_level
    ROOT_LOG_LEVEL            = "ERROR"
  }

  freeform_tags = var.tags

  lifecycle {
    precondition {
      condition     = var.function_image != ""
      error_message = "function_image must be a fully-qualified OCIR image reference (e.g., region.ocir.io/namespace/repo:tag)"
    }
  }

  depends_on = []
}

# Optional: Set up provisioned concurrency for better performance
# Uncomment if desired and adjust count based on expected load
# resource "oci_functions_function" "ssh_check" {
#   ...
#   provisioned_concurrency_config {
#     strategy = "CONSTANT"
#     count    = 2  # Keep 2 warm instances ready
#   }
# }



