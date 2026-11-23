# ---------------------------------------------------------------------------
# Per-CDB CloudWatch dashboards
#
# One dashboard per CDB. Each widget uses a CloudWatch Metrics Insights query
# (SELECT ... FROM SCHEMA(...) WHERE resourceName = '<db>') rather than a
# static metric+dimension array.
#
# Why Metrics Insights: ODB publishes most AWS/ODB metrics at the RAC INSTANCE
# level, with dimensions like hostName/instanceName/instanceNumber (plus
# ioType, waitClass, memoryType/memoryPool for some). A static metric array
# that lists only cluster+resourceName dimensions matches no published series,
# so the widgets render empty. A SCHEMA query matches every series for the DB
# and aggregates across instances. DB-level metrics (storage, FRA, tablespace,
# MonitoringStatus, password expiry) have no per-instance dimensions and use a
# narrower SCHEMA.
#
# Metric names use OCI casing exactly as published (e.g. CpuUtilization, NOT
# CPUUtilization). Only metrics actually emitted for these CDBs are included.
# The resourceName in the query is the database value passed in var.databases,
# which must be the real DB name as it appears in the metric dimensions.
# ---------------------------------------------------------------------------

locals {
  name_prefix = var.dashboard_name_prefix != "" ? var.dashboard_name_prefix : "${var.vm_cluster_name}-CDB"

  # SCHEMA dimension lists (sorted). Metrics Insights requires the SCHEMA to
  # match the full dimension set of the series being selected.
  #
  # DB-level (no per-instance dimensions):
  dims_db = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType"
  # Instance-level (per RAC node):
  dims_inst = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, hostName, instanceName, instanceNumber, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType"
  # Instance-level variants that carry an extra breakdown dimension. Metrics
  # Insights requires SCHEMA to list the EXACT dimension set of the series, so
  # these metrics need their extra dimension or the query returns 0 points.
  dims_inst_io     = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, hostName, instanceName, instanceNumber, ioType, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType"
  dims_inst_wait   = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, hostName, instanceName, instanceNumber, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType, waitClass"
  dims_inst_memory = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, hostName, instanceName, instanceNumber, memoryPool, memoryType, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType"
  # DB-level with collectionName (MonitoringStatus carries this extra dimension,
  # e.g. collectionName="sensor"); without it the SCHEMA matches no series.
  dims_db_status = "cloudExadataInfrastructureId, cloudVmClusterId, collectionName, deploymentType, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType"
  # DB-level per-tablespace (tablespace* dims). One series per tablespace.
  dims_tbsp = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType, tablespaceContents, tablespaceName"
  # Instance-level with parseType (ParsesByType) and transactionStatus
  # (TransactionsByStatus) breakdown dimensions.
  dims_inst_parse = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, hostName, instanceName, instanceNumber, ociCloudExadataInfrastructureId, ociCloudVmClusterId, parseType, resourceId, resourceName, resourceType"
  dims_inst_txn   = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, hostName, instanceName, instanceNumber, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType, transactionStatus"

  # Header markdown: describes every AWS/ODB CDB metric charted below. Rendered
  # as a full-width text widget at the top of each per-CDB dashboard.
  header_markdown = <<-EOT
    # ${var.vm_cluster_name} — Container Database metrics
    Oracle Database@AWS publishes these `AWS/ODB` namespace metrics for each container database (CDB). Widgets below are grouped the way a DBA reviews a database: health first, then activity/workload, I/O and memory, RAC global cache, and finally storage/FRA. CDB-level metrics that break down per RAC instance are aggregated across instances.

    | Metric | Group | Description | Units |
    | --- | --- | --- | --- |
    | MonitoringStatus | Health | Whether metric collection is succeeding for the database. | Status |
    | MonitoringUserPasswordExpiration | Health | Days until the monitoring user's password expires. | Days |
    | CpuUtilization | CPU & Sessions | CPU used as a percent of the CPUs the DB may use (2× OCPUs), across all consumer groups. | Percent |
    | CpuCount | CPU & Sessions | Number of CPUs available to the instance. | Count |
    | DBTime | CPU & Sessions | Average Active Sessions (CPU + wait time accumulation rate). | Sessions |
    | CPUTime | CPU & Sessions | CPU-time component of Average Active Sessions. | sec/sec |
    | Sessions | CPU & Sessions | Number of sessions in the database. | Count |
    | Processes | CPU & Sessions | Number of current processes. | Count |
    | ProcessLimitUtilization | CPU & Sessions | Processes as a percent of the processes limit. | Percent |
    | SessionLimitUtilization | CPU & Sessions | Sessions as a percent of the sessions limit. | Percent |
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
    | RedoGenerationRate | Workload | Rate of redo generation. | MB/sec |
    | IOPS | I/O & Memory | I/O operations per second. | ops/sec |
    | IOThroughput | I/O & Memory | I/O throughput. | MB/sec |
    | WaitTime | I/O & Memory | Wait-time accumulation rate. | sec/sec |
    | MemoryUsage | I/O & Memory | Memory in use (SGA/PGA pools). | MB |
    | InterConnectTraffic | RAC Global Cache | RAC interconnect traffic. | MB/sec |
    | GCCRBlocksReceived | RAC Global Cache | Global-cache CR blocks received per second. | blocks/sec |
    | GCCurrentBlocksReceived | RAC Global Cache | Global-cache current blocks received per second. | blocks/sec |
    | AvgGCCRBlockReceiveTime | RAC Global Cache | Average time to receive a GC CR block. | ms |
    | AvgGCCurrentBlockReceiveTime | RAC Global Cache | Average time to receive a GC current block. | ms |
    | StorageUtilization | Storage & FRA | Provisioned storage capacity in use (all tablespaces). | Percent |
    | StorageAllocated | Storage & FRA | Space allocated to the database. | GB |
    | StorageUsed | Storage & FRA | Space used by the database. | GB |
    | StorageUtilizationByTablespace | Storage & FRA | Space utilized per tablespace (root container). | Percent |
    | AllocatedStorageUtilizationByTablespace | Storage & FRA | Allocated-space utilization per tablespace. | Percent |
    | StorageAllocatedByTablespace | Storage & FRA | Space allocated per tablespace. | GB |
    | StorageUsedByTablespace | Storage & FRA | Space used per tablespace. | GB |
    | MaxTablespaceSize | Storage & FRA | Maximum tablespace size. | GB |
    | FRAUtilization | Storage & FRA | Flash Recovery Area utilization. | Percent |
    | UsableFRA | Storage & FRA | Usable Flash Recovery Area. | Percent |
    | UsedFRASpace | Storage & FRA | Flash Recovery Area space used. | GB |
    | ReclaimableFRA | Storage & FRA | Reclaimable FRA. | Percent |
    | NonReclaimableFRA | Storage & FRA | Non-reclaimable FRA. | Percent |
    | FRASpaceLimit | Storage & FRA | FRA space limit. | GB |
    | ReclaimableFRASpace | Storage & FRA | Reclaimable FRA space. | GB |
  EOT

  # Widget catalog, grouped in DBA-review order. `kind` = "section" emits a
  # full-width sub-header label; otherwise it is a metric widget. stat is the
  # Metrics Insights aggregate; level selects the SCHEMA dimension set.
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
    { metric = "Processes", title = "Process Count", stat = "MAX", period = 300, level = "inst" },
    { metric = "ProcessLimitUtilization", title = "Process Limit Utilization (%)", stat = "AVG", period = 300, level = "inst", pct = true, annotations = [{ label = "Critical", value = 80, color = "#d62728" }] },
    { metric = "SessionLimitUtilization", title = "Session Limit Utilization (%)", stat = "AVG", period = 300, level = "inst", pct = true, annotations = [{ label = "Critical", value = 80, color = "#d62728" }] },
    { metric = "CurrentLogons", title = "Current Logons", stat = "AVG", period = 300, level = "inst" },

    { kind = "section", title = "Workload" },
    { metric = "TransactionCount", title = "Transaction Count", stat = "AVG", period = 300, level = "inst" },
    { metric = "TransactionsByStatus", title = "Transactions By Status (tx/sec)", stat = "AVG", period = 300, level = "inst_txn" },
    { metric = "ExecuteCount", title = "Execute Count", stat = "AVG", period = 300, level = "inst" },
    { metric = "UserCalls", title = "User Calls", stat = "AVG", period = 300, level = "inst" },
    { metric = "ParseCount", title = "Parse Count (parses/sec)", stat = "AVG", period = 300, level = "inst" },
    { metric = "ParsesByType", title = "Parses By Type (parses/sec)", stat = "AVG", period = 300, level = "inst_parse" },
    { metric = "LogicalBlocksRead", title = "Logical Reads (reads/sec)", stat = "AVG", period = 300, level = "inst" },
    { metric = "BlockChanges", title = "Block Changes (changes/sec)", stat = "AVG", period = 300, level = "inst" },
    { metric = "RedoSize", title = "Redo Generated (MB/sec)", stat = "AVG", period = 300, level = "inst" },
    { metric = "RedoGenerationRate", title = "Redo Generation Rate (MB/sec)", stat = "AVG", period = 300, level = "db" },

    { kind = "section", title = "I/O & Memory" },
    { metric = "IOPS", title = "IOPS (ops/sec)", stat = "AVG", period = 300, level = "inst_io" },
    { metric = "IOThroughput", title = "IO Throughput (MB/sec)", stat = "AVG", period = 300, level = "inst_io" },
    { metric = "WaitTime", title = "Wait Time (sec/sec)", stat = "AVG", period = 300, level = "inst_wait" },
    { metric = "MemoryUsage", title = "Memory Usage (MB)", stat = "AVG", period = 900, level = "inst_memory" },

    { kind = "section", title = "RAC Global Cache" },
    { metric = "InterConnectTraffic", title = "Interconnect Traffic (MB/sec)", stat = "AVG", period = 300, level = "inst" },
    { metric = "GCCRBlocksReceived", title = "GC CR Blocks Received (blocks/sec)", stat = "AVG", period = 300, level = "inst" },
    { metric = "GCCurrentBlocksReceived", title = "GC Current Blocks Received (blocks/sec)", stat = "AVG", period = 300, level = "inst" },
    { metric = "AvgGCCRBlockReceiveTime", title = "Avg GC CR Block Receive Time (ms)", stat = "AVG", period = 300, level = "inst" },
    { metric = "AvgGCCurrentBlockReceiveTime", title = "Avg GC Current Block Receive Time (ms)", stat = "AVG", period = 300, level = "inst" },

    { kind = "section", title = "Storage & Flash Recovery Area" },
    { metric = "StorageUtilization", title = "Storage Utilization (%)", stat = "MAX", period = 3600, level = "db", pct = true, annotations = [{ label = "Warning", value = 85, color = "#ff7f0e" }, { label = "Critical", value = 90, color = "#d62728" }] },
    { metric = "StorageAllocated", title = "Storage Allocated (GB)", stat = "MAX", period = 3600, level = "db" },
    { metric = "StorageUsed", title = "Storage Used (GB)", stat = "MAX", period = 3600, level = "db" },
    { metric = "StorageUtilizationByTablespace", title = "Tablespace Utilization (%)", stat = "MAX", period = 3600, level = "tbsp", pct = true, annotations = [{ label = "Warning", value = 85, color = "#ff7f0e" }, { label = "Critical", value = 90, color = "#d62728" }] },
    { metric = "AllocatedStorageUtilizationByTablespace", title = "Allocated Tablespace Utilization (%)", stat = "MAX", period = 3600, level = "tbsp", pct = true },
    { metric = "StorageAllocatedByTablespace", title = "Tablespace Storage Allocated (GB)", stat = "MAX", period = 1800, level = "tbsp" },
    { metric = "StorageUsedByTablespace", title = "Tablespace Storage Used (GB)", stat = "MAX", period = 1800, level = "tbsp" },
    { metric = "MaxTablespaceSize", title = "Max Tablespace Size (GB)", stat = "MAX", period = 1800, level = "tbsp" },
    { metric = "FRAUtilization", title = "Flash Recovery Area Utilization (%)", stat = "AVG", period = 900, level = "db", pct = true, annotations = [{ label = "Warning", value = 80, color = "#ff7f0e" }, { label = "Critical", value = 90, color = "#d62728" }] },
    { metric = "UsableFRA", title = "Usable Flash Recovery Area (%)", stat = "AVG", period = 900, level = "db", pct = true },
    { metric = "UsedFRASpace", title = "Flash Recovery Area Usage (GB)", stat = "MAX", period = 900, level = "db" },
    { metric = "ReclaimableFRA", title = "Reclaimable Flash Recovery Area (%)", stat = "AVG", period = 900, level = "db", pct = true },
    { metric = "NonReclaimableFRA", title = "Non Reclaimable Flash Recovery Area (%)", stat = "AVG", period = 900, level = "db", pct = true },
    { metric = "FRASpaceLimit", title = "FRA Space Limit (GB)", stat = "MAX", period = 900, level = "db" },
    { metric = "ReclaimableFRASpace", title = "Reclaimable FRA Space (GB)", stat = "MAX", period = 900, level = "db" },
  ]

  schema_for = {
    db          = local.dims_db
    db_status   = local.dims_db_status
    tbsp        = local.dims_tbsp
    inst        = local.dims_inst
    inst_io     = local.dims_inst_io
    inst_wait   = local.dims_inst_wait
    inst_memory = local.dims_inst_memory
    inst_parse  = local.dims_inst_parse
    inst_txn    = local.dims_inst_txn
    db_pw       = "cloudExadataInfrastructureId, cloudVmClusterId, deploymentType, isPerpetual, ociCloudExadataInfrastructureId, ociCloudVmClusterId, resourceId, resourceName, resourceType"
  }
}

resource "aws_cloudwatch_dashboard" "this" {
  for_each = toset(var.databases)

  dashboard_name = "${local.name_prefix}-${each.value}"

  # Each widget is encoded then decoded back to `any` so heterogeneous widget
  # shapes (full-width text header, section labels, metric widgets) unify into
  # a single list type — a ?: between two different object types fails
  # Terraform type checking, but jsondecode() yields `any`.
  # x/y omitted: CloudWatch auto-flows widgets left-to-right, wrapping by width.
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
