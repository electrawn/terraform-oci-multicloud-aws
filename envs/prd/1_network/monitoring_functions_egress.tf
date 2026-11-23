# ---------------------------------------------------------------------------
# Egress for ocidb-monitoring OCI Functions (PRD)
# ---------------------------------------------------------------------------
# The ocidb-monitoring PRD functions run in the ODB network's client subnet
# (10.0.129.0/25) so they can reach the three Exadata clusters' DB nodes
# directly. This manages the ODB VCN's default security list to permit:
#   - 1521  Oracle listener  (oracle-service-check login; libcache-check AWR
#           query over SQL*Net, as the ocimon user)
#   - 22    SSH              (ssh-check TCP/banner connectivity probe)
#   - OCI services (service gateway) for Monitoring / Vault / Log Analytics /
#     OCIR — preserved from the existing default rule.
#
# This is a controlled change to shared ODB network infrastructure and must go
# through the standard RFC/change process before apply.

variable "monitoring_functions_db_node_cidr" {
  description = "CIDR of the Exadata client subnet the PRD ocidb-monitoring functions must reach"
  type        = string
  default     = "10.0.129.0/25"
}

variable "monitoring_functions_oci_services_cidr" {
  description = "OCI service-gateway CIDR label for reaching OCI APIs"
  type        = string
  default     = "all-iad-services-in-oracle-services-network"
}

resource "oci_core_default_security_list" "odb_client" {
  # Adopts the ODB VCN's existing default security list.
  manage_default_resource_id = data.oci_core_vcn.odb.default_security_list_id

  # Keep the ODB-assigned name so adopting the list does not rename shared infra.
  display_name = "Default Security List for VCN-${var.aws_odb_network_display_name}"

  # Oracle listener: oracle-service-check login AND libcache-check AWR query
  # (both connect over SQL*Net as the ocimon user) to all three clusters.
  egress_security_rules {
    destination      = var.monitoring_functions_db_node_cidr
    destination_type = "CIDR_BLOCK"
    protocol         = "6" # TCP
    stateless        = false
    description      = "ocidb-monitoring functions -> Exadata nodes Oracle listener"
    tcp_options {
      min = 1521
      max = 1521
    }
  }

  # SSH: ssh-check TCP/banner connectivity probe.
  egress_security_rules {
    destination      = var.monitoring_functions_db_node_cidr
    destination_type = "CIDR_BLOCK"
    protocol         = "6" # TCP
    stateless        = false
    description      = "ocidb-monitoring ssh-check -> Exadata nodes SSH probe"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # OCI service network (via service gateway): Monitoring (publish metrics),
  # Vault (read DB creds), Log Analytics, OCIR (pull images). Preserves the
  # VCN's pre-existing all-TCP OCI-services egress rule.
  egress_security_rules {
    destination      = var.monitoring_functions_oci_services_cidr
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6" # TCP
    stateless        = false
    description      = "ocidb-monitoring functions -> OCI services (Monitoring, Vault, Log Analytics, OCIR)"
  }
}

# Look up the ODB-provisioned VCN so we can manage its default security list.
data "oci_core_vcn" "odb" {
  vcn_id = module.network_odb.aws_odb_network_oci_vcn_id
}
