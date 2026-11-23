# ---------------------------------------------------------------------------
# Oracle service-status alarm targets, per PRD cluster.
#
# REPORTING: one alarm per REPORTING PDB, matching exactly the PDBs the
# oracle-service-check function iterates. The function logs in to the
# read-only service the PDB provides and emits oracle_service_status with
# service_type=reporting and database_name = the lowercase PDB name.
# Alarm: <cluster>-<pdb>-reporting-service-status
#        (e.g. exa3vmc1-pdb051-reporting-service-status).
#
# CPH: one alarm per CPH service (var.cph_services). The function logs in to
# the service on its Data Guard standby and emits service_type=cph with
# database_name = the service name.
# Alarm: <cluster>-<service>-service-status
#        (e.g. exa3vmc1-ee4bwcph_pdb014-service-status).
#
# Reporting PDBs and the CPH standbys live on exa3 (e3c1) only.
# var.cph_services must match the cph_services variable in the oci-functions
# prd stack (which drives what the function checks).
# ---------------------------------------------------------------------------

variable "oracle_service_monitored_roles" {
  description = "PDB roles whose databases get a reporting-service-status alarm."
  type        = list(string)
  default     = ["reporting"]
}

variable "cph_services" {
  description = "CPH services on exa3 (e3c1) to alarm on: connect service name => Data Guard standby DB unique name. Must match the oci-functions prd cph_services."
  type        = map(string)
  default = {
    "ee4bwcph_pdb014" = "ee4bwcpg_exa3vmc1"
    "na4bwcph_pdb023" = "na4bwcpg_exa3vmc1"
    "rw7bwcph_pdb039" = "rw7bwcpg_exa3vmc1"
    "rw8bwcph_pdb040" = "rw8bwcpg_exa3vmc1"
    "we4bwcph_pdb049" = "we4bwcpg_exa3vmc1"
  }
}

variable "reporting_alarm_excluded_pdbs" {
  description = "exa3 reporting-role PDB names (as in OCI, e.g. PDB051) that get NO reporting-service-status alarm. Must match reporting_check_excluded_pdbs in the oci-functions prd stack."
  type        = list(string)
  default     = ["PDB051", "PDB025", "PDB041", "PDB043"]
}

variable "reporting_alarm_extra_pdbs" {
  description = "exa3 reporting PDBs not in 3_databases state that still get a reporting-service-status alarm: PDB name => PDB OCID. Must match reporting_check_extra_pdbs in the oci-functions prd stack."
  type        = map(string)
  default = {
    # PDB013 (cdb009, service pdb504 shared with PDB503); its PDB
    # module is commented out in 3_databases/exa3.
    PDB013 = "ocid1.pluggabledatabase.oc1.iad.exampleuniqueidplugga0002"
  }
}

locals {
  # Reporting PDBs on exa3, keyed "exa3/pdbname", minus
  # var.reporting_alarm_excluded_pdbs, plus var.reporting_alarm_extra_pdbs.
  oracle_service_pdbs_in_scope = merge(
    {
      for name, pdb in local.exa3_pdbs_raw :
      "exa3/${name}" => { cluster = "exa3", name = name, info = pdb }
      if contains(var.oracle_service_monitored_roles, lookup(pdb, "role", "regular"))
      && !contains([for p in var.reporting_alarm_excluded_pdbs : upper(p)], upper(lookup(pdb, "name", name)))
    },
    {
      for name, ocid in var.reporting_alarm_extra_pdbs :
      "exa3/${name}" => { cluster = "exa3", name = name, info = { name = name, ocid = ocid, role = "reporting" } }
    }
  )
}

# Resolve each reporting PDB's name and default connect service from OCI.
data "oci_database_pluggable_database" "oracle_service_alarm" {
  for_each              = local.oracle_service_pdbs_in_scope
  pluggable_database_id = each.value.info.ocid
}

locals {
  oracle_service_alarm_pdb_services = {
    for k, d in data.oci_database_pluggable_database.oracle_service_alarm :
    k => try(
      element(
        split("/", d.connection_strings[0].pdb_default),
        length(split("/", d.connection_strings[0].pdb_default)) - 1
      ),
      null
    )
  }

  # exa3 reporting alarms: lowercase PDB name => service the check tests.
  # One per PDB; the A/B copies sharing a service each get their own alarm.
  reporting_service_alarm_databases_exa3 = {
    for k, svc in local.oracle_service_alarm_pdb_services :
    lower(data.oci_database_pluggable_database.oracle_service_alarm[k].pdb_name) => svc
    if svc != null && svc != ""
  }
}

output "oracle_service_alarm_databases_by_cluster" {
  description = "Per-cluster reporting (PDB name => service) and CPH (service => standby) service-status alarm targets."
  value = {
    exa3 = {
      reporting = local.reporting_service_alarm_databases_exa3
      cph       = var.cph_services
    }
  }
}
