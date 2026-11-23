# ---------------------------------------------------------------------------
# Per-PDB CloudWatch dashboards
#
# One dashboard per PDB. Each widget uses a CloudWatch Metrics Insights query
# (SELECT ... FROM SCHEMA(...) WHERE resourceName = '<db>'), for the same
# reason as the CDB module: ODB publishes most AWS/ODB metrics at the RAC
# instance level, so a static cluster+resourceName dimension array matches no
# series and renders empty. A SCHEMA query matches every series for the PDB
# and aggregates across instances (and tablespaces, where applicable).
#
# Metric names use OCI casing exactly as published (e.g. CpuUtilization). Only
# metrics actually emitted for these PDBs are included. resourceName in the
# query is the value from var.databases and must be the real DB name as it
# appears in the metric dimensions.
# ---------------------------------------------------------------------------

locals {
  name_prefix = var.dashboard_name_prefix != "" ? var.dashboard_name_prefix : "${var.vm_cluster_name}-PDB"

  dims_db          = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType"
  dims_inst        = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, hostName, instanceName, instanceNumber, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType"
  dims_inst_io     = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, hostName, instanceName, instanceNumber, ioType, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType"
  dims_inst_wait   = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, hostName, instanceName, instanceNumber, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType, waitClass"
  dims_inst_memory = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, hostName, instanceName, instanceNumber, memoryPool, memoryType, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType"
  dims_tbsp        = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType, tablespaceContents, tablespaceName"
  dims_db_pw       = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, isPerpetual, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType"
  # DB-level with collectionName (MonitoringStatus carries this extra dimension,
  # e.g. collectionName="sensor"); without it the SCHEMA matches no series.
  dims_db_status = "cloudExadataInfrastructureId, cloudVmClusterId, collectionName, deploymentType, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType"
  # Instance-level with parseType (ParsesByType) and transactionStatus
  # (TransactionsByStatus) breakdown dimensions.
  dims_inst_parse = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, hostName, instanceName, instanceNumber, ociCloudExadataInfrastructureId, ociCloudVmClusterId, parseType, resourceId, resourceName, resourceType"
  dims_inst_txn   = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, hostName, instanceName, instanceNumber, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType, transactionStatus"

  # Header markdown: describes every AWS/ODB PDB metric charted below. Rendered
  # as a full-width text widget at the top of each per-PDB dashboard.
  header_markdown = <<-EOT
    # ${var.vm_cluster_name} — Pluggable Database metrics
    Oracle Database@AWS publishes these `AWS/ODB` namespace metrics for each pluggable database (PDB). Widgets below are grouped the way a DBA reviews a database: health first, then activity/workload, I/O and memory, storage/tablespaces, and object/job health. Instance-level metrics are aggregated across RAC instances.

    | Metric | Group | Description | Units |
    | --- | --- | --- | --- |
    | MonitoringStatus | Health | Whether metric collection is succeeding for the database. | Status |
    | MonitoringUserPasswordExpiration | Health | Days until the monitoring user's password expires. | Days |
    | CpuUtilization | CPU & Sessions | CPU used as a percent of the CPUs the DB may use (2× OCPUs), across all consumer groups. | Percent |
    | CpuCount | CPU & Sessions | Number of CPUs available to the instance. | Count |
    | DBTime | CPU & Sessions | Average Active Sessions (CPU + wait time accumulation rate). | Sessions |
    | CPUTime | CPU & Sessions | CPU-time component of Average Active Sessions. | sec/sec |
    | Sessions | CPU & Sessions | Number of sessions in the database. | Count |
    | CurrentLogons | CPU & Sessions | Successful logons during the interval. | Count |
    | TransactionCount | Workload | User commits + user rollbacks during the interval. | Count |
    | TransactionsByStatus | Workload | Committed vs rolled-back transactions per second. | tx/sec |
    | ExecuteCount | Workload | User and recursive calls that executed SQL. | Count |
    | UserCalls | Workload | Combined logons, parses, and execute calls. | Count |
    | ParseCount | Workload | Hard and soft parses during the interval. | Count |
    | ParsesByType | Workload | Hard vs soft parses per second. | parses/sec |
    | LogicalBlocksRead | Workload | Blocks read from buffer cache per second. | reads/sec |
    | BlockChanges | Workload | Blocks changed per second. | changes/sec |
    | RedoSize | Workload | Redo generated per second. | MB/sec |
    | IOPS | I/O & Memory | I/O operations per second. | ops/sec |
    | IOThroughput | I/O & Memory | I/O throughput. | MB/sec |
    | WaitTime | I/O & Memory | Wait-time accumulation rate. | sec/sec |
    | MemoryUsage | I/O & Memory | Memory in use (SGA/PGA pools). | MB |
    | StorageUtilization | Storage | Provisioned storage capacity in use (all tablespaces). | Percent |
    | StorageAllocated | Storage | Space allocated to the database. | GB |
    | StorageUsed | Storage | Space used by the database. | GB |
    | StorageUtilizationByTablespace | Storage | Space utilized per tablespace. | Percent |
    | AllocatedStorageUtilizationByTablespace | Storage | Allocated-space utilization per tablespace. | Percent |
    | StorageAllocatedByTablespace | Storage | Space allocated per tablespace. | GB |
    | StorageUsedByTablespace | Storage | Space used per tablespace. | GB |
    | MaxTablespaceSize | Storage | Maximum tablespace size. | GB |
    | InvalidObjects | Objects & Jobs | Count of invalid database objects. | Count |
    | ProblematicScheduledDBMSJobs | Objects & Jobs | Count of failed/problematic scheduled DBMS jobs. | Count |
  EOT

  # Widget catalog, grouped in DBA-review order. `kind` = "section" emits a
  # full-width sub-header label; otherwise it is a metric widget.
  widgets = [
    { kind = "section", title = "Health" },
    { metric = "MonitoringStatus", title = "Monitoring Status", stat = "MAX", period = 300, level = "db_status", full_width = true },
    { metric = "MonitoringUserPasswordExpiration", title = "Monitoring User Password Expiration (days)", stat = "MIN", period = 3600, level = "db_pw", annotations = [{ label = "Warning", value = 7, color = "#ff7f0e" }, { label = "Critical", value = 3, color = "#d62728" }] },

    { kind = "section", title = "CPU & Sessions" },
    { metric = "CpuUtilization", title = "CPU Utilization (%)", stat = "MAX", period = 300, level = "inst", pct = true, annotations = [{ label = "Critical", value = 80, color = "#d62728" }] },
    { metric = "CpuCount", title = "CPU Count", stat = "MAX", period = 900, level = "inst" },
    { metric = "DBTime", title = "DB Time (Average Active Sessions)", stat = "AVG", period = 300, level = "inst" },
    { metric = "CPUTime", title = "CPU Time (sec/sec)", stat = "AVG", period = 300, level = "inst" },
    { metric = "Sessions", title = "Sessions", stat = "AVG", period = 300, level = "inst" },
    { metric = "CurrentLogons", title = "Current Logons", stat = "AVG", period = 300, level = "inst" },

    { kind = "section", title = "Workload" },
    { metric = "TransactionCount", title = "Transaction Count", stat = "AVG", period = 300, level = "inst" },
    { metric = "TransactionsByStatus", title = "Transactions By Status (tx/sec)", stat = "AVG", period = 300, level = "inst_txn" },
    { metric = "ExecuteCount", title = "Execute Count", stat = "AVG", period = 300, level = "inst" },
    { metric = "UserCalls", title = "User Calls", stat = "AVG", period = 300, level = "inst" },
    { metric = "ParseCount", title = "Parse Count", stat = "AVG", period = 300, level = "inst" },
    { metric = "ParsesByType", title = "Parses By Type (parses/sec)", stat = "AVG", period = 300, level = "inst_parse" },
    { metric = "LogicalBlocksRead", title = "Logical Reads (reads/sec)", stat = "AVG", period = 300, level = "inst" },
    { metric = "BlockChanges", title = "Block Changes (changes/sec)", stat = "AVG", period = 300, level = "inst" },
    { metric = "RedoSize", title = "Redo Generated (MB/sec)", stat = "AVG", period = 300, level = "inst" },

    { kind = "section", title = "I/O & Memory" },
    { metric = "IOPS", title = "IOPS (ops/sec)", stat = "AVG", period = 300, level = "inst_io" },
    { metric = "IOThroughput", title = "IO Throughput (MB/sec)", stat = "AVG", period = 300, level = "inst_io" },
    { metric = "WaitTime", title = "Wait Time (sec/sec)", stat = "AVG", period = 300, level = "inst_wait" },
    { metric = "MemoryUsage", title = "Memory Usage (MB)", stat = "AVG", period = 900, level = "inst_memory" },

    { kind = "section", title = "Storage & Tablespaces" },
    { metric = "StorageUtilization", title = "Storage Utilization (%)", stat = "MAX", period = 3600, level = "db", pct = true, annotations = [{ label = "Warning", value = 85, color = "#ff7f0e" }, { label = "Critical", value = 90, color = "#d62728" }] },
    { metric = "StorageAllocated", title = "Storage Allocated (GB)", stat = "MAX", period = 3600, level = "db" },
    { metric = "StorageUsed", title = "Storage Used (GB)", stat = "MAX", period = 3600, level = "db" },
    { metric = "StorageUtilizationByTablespace", title = "Tablespace Utilization (%)", stat = "MAX", period = 3600, level = "tbsp", pct = true, annotations = [{ label = "Warning", value = 85, color = "#ff7f0e" }, { label = "Critical", value = 90, color = "#d62728" }] },
    { metric = "AllocatedStorageUtilizationByTablespace", title = "Allocated Tablespace Utilization (%)", stat = "MAX", period = 3600, level = "tbsp", pct = true },
    { metric = "StorageAllocatedByTablespace", title = "Tablespace Storage Allocated (GB)", stat = "MAX", period = 1800, level = "tbsp" },
    { metric = "StorageUsedByTablespace", title = "Tablespace Storage Used (GB)", stat = "MAX", period = 1800, level = "tbsp" },
    { metric = "MaxTablespaceSize", title = "Max Tablespace Size (GB)", stat = "MAX", period = 1800, level = "tbsp" },

    { kind = "section", title = "Objects & Jobs" },
    { metric = "InvalidObjects", title = "Invalid Objects", stat = "MAX", period = 86400, level = "db" },
    { metric = "ProblematicScheduledDBMSJobs", title = "Problematic Scheduled DBMS Jobs", stat = "MAX", period = 900, level = "db" },
  ]

  schema_for = {
    db          = local.dims_db
    db_status   = local.dims_db_status
    inst        = local.dims_inst
    inst_io     = local.dims_inst_io
    inst_wait   = local.dims_inst_wait
    inst_memory = local.dims_inst_memory
    inst_parse  = local.dims_inst_parse
    inst_txn    = local.dims_inst_txn
    tbsp        = local.dims_tbsp
    db_pw       = local.dims_db_pw
  }
}

resource "aws_cloudwatch_dashboard" "this" {
  for_each = toset(var.databases)

  dashboard_name = "${local.name_prefix}-${each.value}"

  # Each widget is encoded then decoded back to `any` so heterogeneous widget
  # shapes (full-width text header, section labels, metric widgets) unify into
  # a single list type. First widget is a full-width markdown header; then
  # section labels and metric widgets in DBA-review order.
  dashboard_body = jsonencode({
    widgets = [
      for s in concat(
        [
          jsonencode({
            type       = "text"
            width      = 24
            height     = 8
            properties = { markdown = "${local.header_markdown}\n_Database: **${each.value}**_" }
          })
        ],
        [
          for w in local.widgets : (
            lookup(w, "kind", "metric") == "section"
            ? jsonencode({
              type       = "text"
              width      = 24
              height     = 1
              properties = { markdown = "## ${w.title}" }
            })
            : jsonencode({
              type   = "metric"
              width  = lookup(w, "full_width", false) ? 24 : 12
              height = 6
              properties = merge(
                {
                  title  = w.title
                  region = var.region
                  view   = "timeSeries"
                  period = w.period
                  metrics = [
                    [{
                      expression = "SELECT ${w.stat}(${w.metric}) FROM SCHEMA(\"AWS/ODB\", ${local.schema_for[w.level]}) WHERE resourceName = '${each.value}'"
                      label      = w.title
                      id         = "q_${lower(replace(w.metric, "/[^A-Za-z0-9]/", ""))}"
                    }]
                  ]
                },
                lookup(w, "pct", false) ? { yAxis = { left = { min = 0, max = 100 } } } : {},
                length(lookup(w, "annotations", [])) > 0 ? { annotations = { horizontal = w.annotations } } : {}
              )
            })
          )
        ]
      ) : jsondecode(s)
    ]
  })
}
