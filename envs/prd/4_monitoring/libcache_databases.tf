# ---------------------------------------------------------------------------
# libcache_waiting_sessions alarm targets, per PRD cluster.
#
# One WARNING alarm per in-scope PDB, matching exactly the PDBs each cluster's
# libcache-mutex function iterates (same role filter). The function connects
# with each PDB's default service but emits libcache_mutex_waiting_sessions
# with a database_name dimension = the PDB NAME (OCI pdb_name), so the alarm
# list is the PDB names.
#
# Roles monitored (per DBA): template, regular, dataguard_primary.
# Excluded: dataguard_standby, reporting.
#
# exa3 (e3c1) has no libcache check (no ocimon per DBA), so no list is built
# for it and its custom_metrics_monitoring_exa3 keeps libcache disabled.
# ---------------------------------------------------------------------------

variable "libcache_monitored_roles" {
  description = "PDB roles whose databases get a libcache warning alarm."
  type        = list(string)
  default     = ["template", "regular", "dataguard_primary"]
}

locals {
  # In-scope PDBs per libcache-enabled cluster, keyed "exaN/pdbname".
  libcache_pdbs_in_scope = merge(
    {
      for name, pdb in local.exa1_pdbs_raw :
      "exa1/${name}" => { cluster = "exa1", name = name, info = pdb }
      if contains(var.libcache_monitored_roles, lookup(pdb, "role", "regular"))
    },
    {
      for name, pdb in local.exa2_pdbs_raw :
      "exa2/${name}" => { cluster = "exa2", name = name, info = pdb }
      if contains(var.libcache_monitored_roles, lookup(pdb, "role", "regular"))
    }
  )
}

# Resolve each in-scope PDB's default connect service from OCI (not in state).
data "oci_database_pluggable_database" "libcache_alarm" {
  for_each              = local.libcache_pdbs_in_scope
  pluggable_database_id = each.value.info.ocid
}

locals {
  # Service name = part after the last "/" of the pdb-default connect string.
  libcache_alarm_pdb_services = {
    for k, d in data.oci_database_pluggable_database.libcache_alarm :
    k => try(
      element(
        split("/", d.connection_strings[0].pdb_default),
        length(split("/", d.connection_strings[0].pdb_default)) - 1
      ),
      null
    )
  }

  # Per-cluster PDB-name list (one warning alarm per PDB; alarm name and
  # database_name filter = OCI pdb_name, which is the dimension the function
  # emits). Drop PDBs that did not resolve a service: the function cannot
  # connect to them (e.g. stale/unreachable entries).
  libcache_alarm_pdb_names_by_cluster = {
    for ck in ["exa1", "exa2"] : ck => [
      for k, entry in local.libcache_pdbs_in_scope : data.oci_database_pluggable_database.libcache_alarm[k].pdb_name
      if entry.cluster == ck && local.libcache_alarm_pdb_services[k] != null && local.libcache_alarm_pdb_services[k] != ""
    ]
  }

  libcache_alarm_databases_exa1 = sort(distinct(local.libcache_alarm_pdb_names_by_cluster["exa1"]))
  libcache_alarm_databases_exa2 = sort(distinct(local.libcache_alarm_pdb_names_by_cluster["exa2"]))
}

output "libcache_alarm_databases_by_cluster" {
  description = "Per-cluster PDB names that get a libcache_mutex_waiting_sessions warning alarm (role-filtered)."
  value = {
    exa1 = local.libcache_alarm_databases_exa1
    exa2 = local.libcache_alarm_databases_exa2
  }

  # PDB names are not guaranteed unique on a cluster (service names are). Two
  # in-scope PDBs with the same name on one cluster would share one metric
  # series and alarm, so fail the plan instead of silently merging them.
  precondition {
    condition = alltrue([
      length(local.libcache_alarm_pdb_names_by_cluster["exa1"]) == length(local.libcache_alarm_databases_exa1),
      length(local.libcache_alarm_pdb_names_by_cluster["exa2"]) == length(local.libcache_alarm_databases_exa2),
    ])
    error_message = "Duplicate PDB names on one cluster among libcache alarm targets: ${jsonencode(local.libcache_alarm_pdb_names_by_cluster)}"
  }
}
