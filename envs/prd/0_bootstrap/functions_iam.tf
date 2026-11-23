# ---------------------------------------------------------------------------
# Resource-principal IAM for the ocidb-monitoring OCI Functions (oci-functions
# repo, terraform/env/prd).
#
# The functions (ssh-check, libcache-mutex, oracle-service-check,
# clmn-failed-metrics) run as resource principals matched by this dynamic
# group, and the policy lets them publish custom metrics, read the ocimon DB
# credential secret, and discover DB nodes / VNICs.
#
# Environment IAM belongs in the bootstrap stage, next to the Resource
# Scheduler IAM above. These resources were originally created by the
# oci-functions stack; they are adopted here with import blocks (no
# recreate) and released from the oci-functions state with removed blocks.
# ---------------------------------------------------------------------------

resource "oci_identity_dynamic_group" "prd_functions" {
  compartment_id = var.oci_tenancy_ocid
  name           = "ocidb-monitoring-functions-prd-dg"
  description    = "Dynamic group for ocidb-monitoring functions in PRD compartment ${oci_identity_compartment.monitor_prd.id}"
  matching_rule  = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${oci_identity_compartment.monitor_prd.id}'}"
}

resource "oci_identity_policy" "prd_functions" {
  compartment_id = var.oci_tenancy_ocid
  name           = "ocidb-monitoring-functions-prd-policy"
  description    = "Allow ocidb-monitoring PRD functions to publish metrics, read secrets, and discover DB nodes"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to use metrics in compartment id ${oci_identity_compartment.monitor_prd.id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to read secret-family in compartment id ${oci_identity_compartment.monitor_prd.id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to use keys in compartment id ${oci_identity_compartment.monitor_prd.id}",
    # The ocimon DB-credentials secret lives in the shared vault compartment
    # (the parent compartment of the monitor compartments).
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to read secret-family in compartment id ${var.parent_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to use keys in compartment id ${var.parent_compartment_ocid}",
    # ssh-check discovers Exadata DB nodes via the OCI API, and metrics are
    # also published from the DB compartment where the clusters live.
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to read database-family in compartment id ${var.oci_resource_anchor_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to use metrics in compartment id ${var.oci_resource_anchor_compartment_ocid}",
    # ssh-check resolves each DB node's client IP via its VNIC (get_vnic).
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to read virtual-network-family in compartment id ${var.oci_resource_anchor_compartment_ocid}",
    # pdb-cost-report: read the tenancy's cost data (usage API is tenancy-scoped),
    # map Recovery Service backups to CDBs, and write the report bucket only.
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to read usage-report in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to read recovery-service-family in compartment id ${var.oci_resource_anchor_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to manage objects in compartment id ${oci_identity_compartment.monitor_prd.id} where target.bucket.name = 'ocidb-cost-reports-prd'",
    # pdb-cost-report email: create/delete read-only PAR links on the report
    # bucket only (PAR_MANAGE, nothing else on the bucket), and publish to the
    # report Notifications topic in the monitor compartment.
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to manage buckets in compartment id ${oci_identity_compartment.monitor_prd.id} where all {target.bucket.name = 'ocidb-cost-reports-prd', request.permission = 'PAR_MANAGE'}",
    "Allow dynamic-group ${oci_identity_dynamic_group.prd_functions.name} to use ons-topics in compartment id ${oci_identity_compartment.monitor_prd.id} where request.permission = 'ONS_TOPIC_PUBLISH'",
  ]
}

import {
  to = oci_identity_dynamic_group.prd_functions
  id = "ocid1.dynamicgroup.oc1..exampleuniqueiddynami0002"
}

import {
  to = oci_identity_policy.prd_functions
  id = "ocid1.policy.oc1..exampleuniqueidpolicy0002"
}