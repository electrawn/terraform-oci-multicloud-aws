# ---------------------------------------------------------------------------
# libcache_mutex_waiting_sessions alarm targets.
#
# One WARNING alarm per in-scope PDB, matching exactly the PDBs the
# libcache-mutex function iterates (same role filter). The function connects
# with each PDB's default service but emits the metric with a database_name
# dimension = the PDB NAME (OCI pdb_name, e.g. PDB507), so the alarm list is
# the PDB names.
#
# Roles monitored (per DBA): template, regular, dataguard_primary.
# Excluded: dataguard_standby, reporting.
# ---------------------------------------------------------------------------

variable "libcache_monitored_roles" {
  description = "PDB roles whose databases get a libcache warning alarm."
  type        = list(string)
  default     = ["template", "regular", "dataguard_primary"]
}

locals {
  # In-scope PDBs from the enriched map (role-filtered). Unlabeled => regular.
  libcache_pdbs_in_scope = {
    for name, pdb in local.pdbs :
    name => pdb
    if contains(var.libcache_monitored_roles, lookup(pdb, "role", "regular"))
  }
}

# Resolve each in-scope PDB's name and default connect service from OCI.
data "oci_database_pluggable_database" "libcache_alarm" {
  for_each              = local.libcache_pdbs_in_scope
  pluggable_database_id = each.value.ocid
}

locals {
  # Service name = part after the last "/" of the pdb-default connect string.
  # Only used to drop PDBs the function cannot connect to (no service), so the
  # alarm set matches the PDBs the function actually checks.
  libcache_pdb_services = {
    for name, d in data.oci_database_pluggable_database.libcache_alarm :
    name => try(
      element(
        split("/", d.connection_strings[0].pdb_default),
        length(split("/", d.connection_strings[0].pdb_default)) - 1
      ),
      null
    )
  }

  # PDB-name list fed to the custom_metrics_monitoring module: one warning
  # alarm per PDB (alarm name + database_name filter = PDB name).
  libcache_alarm_pdb_names = [
    for name, d in data.oci_database_pluggable_database.libcache_alarm :
    d.pdb_name
    if local.libcache_pdb_services[name] != null && local.libcache_pdb_services[name] != ""
  ]
  libcache_alarm_databases = sort(distinct(local.libcache_alarm_pdb_names))
}

output "libcache_alarm_databases" {
  description = "PDB names that get a libcache_mutex_waiting_sessions warning alarm (role-filtered)."
  value       = local.libcache_alarm_databases

  # PDB names are not guaranteed unique on a cluster (service names are). Two
  # in-scope PDBs with the same name would share one metric series and alarm,
  # so fail the plan instead of silently merging them.
  precondition {
    condition     = length(local.libcache_alarm_pdb_names) == length(local.libcache_alarm_databases)
    error_message = "Duplicate PDB names among libcache alarm targets: ${join(", ", sort(local.libcache_alarm_pdb_names))}"
  }
}
