# ---------------------------------------------------------------------------
# Egress for ocidb-monitoring OCI Functions
# ---------------------------------------------------------------------------
# The ocidb-monitoring functions (ssh-check, libcache-check,
# oracle-service-check) run in the ODB network's client subnet so they can
# reach the Exadata DB nodes directly. The ODB-provisioned VCN ships with an
# empty default security list (no egress), which blocks all outbound traffic
# from the functions.
#
# This manages that default security list to permit the functions to reach:
#   - 1521  Oracle listener  (oracle-service-check login test; libcache-check
#           GV$SESSION_WAIT query over SQL*Net)
#   - 22    SSH              (ssh-check TCP/banner connectivity probe only)
#   - 443   OCI services     (Monitoring, Vault, Log Analytics via svc gateway)
# scoped to the client subnet CIDR / OCI service network.
#
# NOTE: This is a controlled change to shared ODB network infrastructure and
# must go through the standard RFC/change process before apply.

variable "monitoring_functions_db_node_cidr" {
  description = "CIDR of the Exadata client subnet the ocidb-monitoring functions must reach"
  type        = string
  default     = "10.0.128.0/25"
}

variable "monitoring_functions_oci_services_cidr" {
  description = "OCI service-gateway CIDR label for reaching OCI APIs (Monitoring, Vault, Log Analytics)"
  type        = string
  default     = "all-iad-services-in-oracle-services-network"
}

resource "oci_core_default_security_list" "odb_client" {
  # Adopts the ODB VCN's existing default security list.
  manage_default_resource_id = data.oci_core_vcn.odb.default_security_list_id

  # Keep the ODB-assigned name (adopting the list must not rename shared infra).
  display_name = "Default Security List for VCN-${var.aws_odb_network_display_name}"

  # Oracle listener: oracle-service-check login test AND libcache-check
  # GV$SESSION_WAIT query (both connect over SQL*Net as the ocimon user).
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

  # SSH: ssh-check TCP/banner connectivity probe only. (libcache-check no
  # longer uses SSH; it queries over 1521 above.)
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

  # OCI service network (via the subnet's service gateway): required so the
  # functions can reach the Monitoring API (publish metrics), OCI Vault (read
  # DB credentials), and Log Analytics (clmn-failed-metrics queries). Without
  # this, functions in the locked-down ODB subnet cannot reach any OCI API.
  egress_security_rules {
    destination      = var.monitoring_functions_oci_services_cidr
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6" # TCP
    stateless        = false
    description      = "ocidb-monitoring functions -> OCI services (Monitoring, Vault, Log Analytics)"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

# Look up the ODB-provisioned VCN so we can manage its default security list.
data "oci_core_vcn" "odb" {
  vcn_id = module.network_odb.aws_odb_network_oci_vcn_id
}
