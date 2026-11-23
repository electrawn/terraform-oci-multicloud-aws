# ---------------------------------------------------------------------------
# OCI CDB management dashboards (oracle_oci_database namespace)
#
# The OCI-side equivalent of the CloudWatch per-CDB dashboards. One OCI
# Management Dashboard per CDB, charting the CDB-applicable metrics from the
# oracle_oci_database namespace. Metrics key on the resourceId dimension
# (database OCID).
#
# Metric names follow OCI casing (e.g. CpuUtilization), which differs from the
# AWS/ODB CloudWatch names (CPUUtilization). Reference:
# https://docs.oracle.com/en-us/iaas/database-management/doc/oracle-cloud-database-metrics.html
# ---------------------------------------------------------------------------

locals {
  name_prefix = var.dashboard_name_prefix != "" ? var.dashboard_name_prefix : "${var.vm_cluster_name}-CDB"

  # Metric widget catalog (OCI metric names + MQL statistic/window). Two tiles
  # per row, each 6 columns wide and 3 rows tall, in catalog order.
  metric_widgets = [
    { key = "cpu", metric = "CpuUtilization", title = "CPU Utilization (%)", statistic = "max", window = "5m" },
    { key = "storage", metric = "StorageUtilization", title = "Storage Utilization (%)", statistic = "max", window = "1h" },
    { key = "process_limit", metric = "ProcessLimitUtilization", title = "Process Limit Utilization (%)", statistic = "mean", window = "5m" },
    { key = "session_limit", metric = "SessionLimitUtilization", title = "Session Limit Utilization (%)", statistic = "mean", window = "5m" },
    { key = "sessions", metric = "Sessions", title = "Sessions", statistic = "mean", window = "5m" },
    { key = "processes", metric = "Processes", title = "Process Count", statistic = "max", window = "5m" },
    { key = "db_time", metric = "DBTime", title = "DB Time (Average Active Sessions)", statistic = "mean", window = "5m" },
    { key = "cpu_time", metric = "CPUTime", title = "CPU Time (sec/sec)", statistic = "mean", window = "5m" },
    { key = "wait_time", metric = "WaitTime", title = "Wait Time (sec/sec)", statistic = "mean", window = "5m" },
    { key = "iops", metric = "IOPS", title = "IOPS (ops/sec)", statistic = "mean", window = "5m" },
    { key = "io_throughput", metric = "IOThroughput", title = "IO Throughput (MB/sec)", statistic = "mean", window = "5m" },
    { key = "logical_reads", metric = "LogicalBlocksRead", title = "Logical Reads (reads/sec)", statistic = "mean", window = "5m" },
    { key = "redo_size", metric = "RedoSize", title = "Redo Generated (MB/sec)", statistic = "mean", window = "5m" },
    { key = "memory", metric = "MemoryUsage", title = "Memory Usage (MB)", statistic = "mean", window = "15m" },
    { key = "fra", metric = "FRAUtilization", title = "Flash Recovery Area Utilization (%)", statistic = "mean", window = "15m" },
    { key = "usable_fra", metric = "UsableFRA", title = "Usable Flash Recovery Area (%)", statistic = "mean", window = "15m" },
    { key = "used_fra", metric = "UsedFRASpace", title = "Flash Recovery Area Usage (GB)", statistic = "max", window = "15m" },
    { key = "apply_lag", metric = "ApplyLag", title = "Apply Lag (seconds)", statistic = "max", window = "5m" },
    { key = "transport_lag", metric = "TransportLag", title = "Transport Lag (seconds)", statistic = "max", window = "5m" },
    { key = "redo_apply_rate", metric = "RedoApplyRate", title = "Redo Apply Rate (MB/sec)", statistic = "mean", window = "5m" },
    { key = "redo_gen_rate", metric = "RedoGenerationRate", title = "Redo Generation Rate (MB/sec)", statistic = "mean", window = "5m" },
    { key = "password_expiry", metric = "MonitoringUserPasswordExpiration", title = "Monitoring User Password Expiration (days)", statistic = "last", window = "1d" },
  ]

  # Recovery Service (ZDLRA) widgets, appended only for CDBs that have a
  # protected-database OCID in var.protected_databases. These query the
  # oci_recovery_service namespace keyed on the protected-database OCID.
  # ProtectedDatabaseHealth: 0 = Protected, 1 = Warning, 2 = Alert/backup failed.
  zdlra_widgets = [
    { key = "zdlra_health", metric = "ProtectedDatabaseHealth", title = "ZDLRA Protected DB Health (0=OK,1=Warn,2=Alert)", statistic = "max", window = "30m" },
    { key = "zdlra_dle", metric = "DataLossExposure", title = "ZDLRA Data Loss Exposure (seconds)", statistic = "mean", window = "30m" },
    { key = "zdlra_size", metric = "ProtectedDatabaseSize", title = "ZDLRA Protected DB Size (GB)", statistic = "max", window = "1d" },
    { key = "zdlra_recwin", metric = "SpaceUsedForRecoveryWindow", title = "ZDLRA Space Used for Recovery Window (GB)", statistic = "max", window = "1d" },
  ]
}

# All CDB dashboards are imported in a SINGLE resource / API call. The OCI
# ImportDashboard API accepts an array of dashboards, and doing them in one
# call avoids the parallel-write race in the SplatStore backend that occurs
# when Terraform creates many import resources concurrently via for_each
# (which surfaced as intermittent 401 / RelatedResourceNotAuthorizedOrNotFound
# "Cannot find Resource ...managementsavedsearch..." errors).
resource "oci_management_dashboard_management_dashboards_import" "this" {
  count = length(var.databases) > 0 ? 1 : 0

  override_same_name                  = true
  override_dashboard_compartment_ocid = var.compartment_ocid

  import_details = jsonencode({
    dashboards = [
      for db_name, db_ocid in var.databases : {
        dashboardId       = "cdb-${lower(replace(var.vm_cluster_name, "/[^A-Za-z0-9]/", ""))}-${lower(db_name)}"
        displayName       = "${local.name_prefix}-${db_name}"
        description       = "Oracle CDB metrics (oracle_oci_database) for ${db_name} (${var.environment})."
        compartmentId     = var.compartment_ocid
        providerId        = "management-dashboard"
        providerName      = "Management Dashboard"
        providerVersion   = "3.0.0"
        isOobDashboard    = false
        isShowInHome      = false
        isShowDescription = true
        isFavorite        = false
        metadataVersion   = "2.0"
        type              = "normal"
        screenImage       = ""
        freeformTags      = {}
        definedTags       = {}
        nls               = {}
        uiConfig = {
          isFilteringEnabled = true
          isTimeRangeEnabled = true
          isRefreshEnabled   = true
        }
        dataConfig = []

        # Per-DB widget list: the standard oracle_oci_database widgets, plus the
        # Recovery Service (ZDLRA) widgets when this CDB has a protected-DB OCID.
        # Each widget carries its own namespace + resourceId so tiles and saved
        # searches build uniformly from one list.
        tiles = [
          for idx, w in concat(
            [for s in local.metric_widgets : merge(s, { namespace = "oracle_oci_database", resource_id = db_ocid })],
            contains(keys(var.protected_databases), db_name) ? [for z in local.zdlra_widgets : merge(z, { namespace = "oci_recovery_service", resource_id = var.protected_databases[db_name] })] : []
            ) : {
            displayName     = w.title
            savedSearchId   = "cdb-ss-${lower(db_name)}-${w.key}"
            row             = floor(idx / 2) * 3
            column          = (idx % 2) * 6
            height          = 3
            width           = 6
            nls             = {}
            dataConfig      = []
            drilldownConfig = []
            state           = "DEFAULT"
            uiConfig        = { vizType = "line" }
          }
        ]

        savedSearches = [
          for idx, w in concat(
            [for s in local.metric_widgets : merge(s, { namespace = "oracle_oci_database", resource_id = db_ocid })],
            contains(keys(var.protected_databases), db_name) ? [for z in local.zdlra_widgets : merge(z, { namespace = "oci_recovery_service", resource_id = var.protected_databases[db_name] })] : []
            ) : {
            id               = "cdb-ss-${lower(db_name)}-${w.key}"
            displayName      = w.title
            description      = "${w.namespace} ${w.metric} for ${db_name}"
            compartmentId    = var.compartment_ocid
            providerId       = "management-dashboard"
            providerName     = "Management Dashboard"
            providerVersion  = "3.0.0"
            type             = "WIDGET_SHOW_IN_DASHBOARD"
            isOobSavedSearch = false
            metadataVersion  = "2.0"
            screenImage      = ""
            nls              = {}
            freeformTags     = {}
            definedTags      = {}
            widgetTemplate   = "visualizations/chartWidgetTemplate.html"
            widgetVM         = "visualizations/chartWidget"
            uiConfig         = { vizType = "line" }
            dataConfig = [
              {
                type      = "MQL"
                name      = w.metric
                region    = var.region
                namespace = w.namespace
                query     = "${w.metric}[${w.window}]{resourceId = \"${w.resource_id}\"}.${w.statistic}()"
              }
            ]
          }
        ]
      }
    ]
  })
}
