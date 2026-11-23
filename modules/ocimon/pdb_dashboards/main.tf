# ---------------------------------------------------------------------------
# OCI PDB management dashboards (oracle_oci_database namespace)
#
# The OCI-side equivalent of the CloudWatch per-PDB dashboards. One OCI
# Management Dashboard per PDB, charting the PDB-applicable metrics from the
# oracle_oci_database namespace. Metrics key on the resourceId dimension
# (database OCID).
#
# Metric names follow OCI casing (e.g. CpuUtilization). Reference:
# https://docs.oracle.com/en-us/iaas/database-management/doc/oracle-cloud-database-metrics.html
# ---------------------------------------------------------------------------

locals {
  name_prefix = var.dashboard_name_prefix != "" ? var.dashboard_name_prefix : "${var.vm_cluster_name}-PDB"

  # Metric widget catalog (OCI metric names + MQL statistic/window). Two tiles
  # per row, each 6 columns wide and 3 rows tall, in catalog order.
  metric_widgets = [
    { key = "cpu", metric = "CpuUtilization", title = "CPU Utilization (%)", statistic = "max", window = "5m" },
    { key = "storage", metric = "StorageUtilization", title = "Storage Utilization (%)", statistic = "max", window = "1h" },
    { key = "tablespace", metric = "StorageUtilizationByTablespace", title = "Tablespace Utilization (%)", statistic = "max", window = "1h" },
    { key = "alloc_tablespace", metric = "AllocatedStorageUtilizationByTablespace", title = "Allocated Tablespace Utilization (%)", statistic = "mean", window = "30m" },
    { key = "max_tablespace", metric = "MaxTablespaceSize", title = "Max Tablespace Size (GB)", statistic = "max", window = "30m" },
    { key = "cpus_enabled", metric = "CpusEnabled", title = "CPUs Enabled", statistic = "mean", window = "1h" },
    { key = "sessions", metric = "Sessions", title = "Sessions", statistic = "mean", window = "5m" },
    { key = "blocking_sessions", metric = "BlockingSessions", title = "Blocking Sessions", statistic = "max", window = "15m" },
    { key = "db_time", metric = "DBTime", title = "DB Time (Average Active Sessions)", statistic = "mean", window = "5m" },
    { key = "cpu_time", metric = "CPUTime", title = "CPU Time (sec/sec)", statistic = "mean", window = "5m" },
    { key = "wait_time", metric = "WaitTime", title = "Wait Time (sec/sec)", statistic = "mean", window = "5m" },
    { key = "iops", metric = "IOPS", title = "IOPS (ops/sec)", statistic = "mean", window = "5m" },
    { key = "io_throughput", metric = "IOThroughput", title = "IO Throughput (MB/sec)", statistic = "mean", window = "5m" },
    { key = "logical_reads", metric = "LogicalBlocksRead", title = "Logical Reads (reads/sec)", statistic = "mean", window = "5m" },
    { key = "redo_size", metric = "RedoSize", title = "Redo Generated (MB/sec)", statistic = "mean", window = "5m" },
    { key = "transactions", metric = "TransactionsByStatus", title = "Transactions By Status (tx/sec)", statistic = "mean", window = "5m" },
    { key = "parses", metric = "ParsesByType", title = "Parses By Type (parses/sec)", statistic = "mean", window = "5m" },
    { key = "memory", metric = "MemoryUsage", title = "Memory Usage (MB)", statistic = "mean", window = "15m" },
    { key = "invalid_objects", metric = "InvalidObjects", title = "Invalid Objects", statistic = "max", window = "1d" },
    { key = "unusable_indexes", metric = "UnusableIndexes", title = "Unusable Indexes", statistic = "max", window = "1d" },
    { key = "problematic_jobs", metric = "ProblematicScheduledDBMSJobs", title = "Problematic Scheduled DBMS Jobs", statistic = "max", window = "15m" },
    { key = "password_expiry", metric = "MonitoringUserPasswordExpiration", title = "Monitoring User Password Expiration (days)", statistic = "last", window = "1d" },
  ]
}

# All PDB dashboards are imported in a SINGLE resource / API call to avoid the
# parallel-write race in the SplatStore backend that occurs when Terraform
# creates many import resources concurrently via for_each.
resource "oci_management_dashboard_management_dashboards_import" "this" {
  count = length(var.databases) > 0 ? 1 : 0

  override_same_name                  = true
  override_dashboard_compartment_ocid = var.compartment_ocid

  import_details = jsonencode({
    dashboards = [
      for db_name, db_ocid in var.databases : {
        dashboardId       = "pdb-${lower(replace(var.vm_cluster_name, "/[^A-Za-z0-9]/", ""))}-${lower(db_name)}"
        displayName       = "${local.name_prefix}-${db_name}"
        description       = "Oracle PDB metrics (oracle_oci_database) for ${db_name} (${var.environment})."
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

        tiles = [
          for idx, w in local.metric_widgets : {
            displayName     = w.title
            savedSearchId   = "pdb-ss-${lower(db_name)}-${w.key}"
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
          for idx, w in local.metric_widgets : {
            id               = "pdb-ss-${lower(db_name)}-${w.key}"
            displayName      = w.title
            description      = "oracle_oci_database ${w.metric} for ${db_name}"
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
                namespace = "oracle_oci_database"
                query     = "${w.metric}[${w.window}]{resourceId = \"${db_ocid}\"}.${w.statistic}()"
              }
            ]
          }
        ]
      }
    ]
  })
}
