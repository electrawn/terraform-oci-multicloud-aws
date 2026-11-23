# ---------------------------------------------------------------------------
# ALL CDB Databases dashboard (one per VM cluster).
#
# Each widget charts every CDB on the cluster as a separate series using a
# CloudWatch Metrics Insights query:
#   SELECT <stat>(<metric>) FROM "AWS/ODB"
#   WHERE cloudVmClusterId = '<vmc>' AND resourceType = 'CDB'
#   GROUP BY resourceName
# GROUP BY resourceName produces one line per database and auto-discovers every
# CDB on the cluster (no per-DB list needed). Metrics that carry extra
# dimensions (tablespace, ioType, parseType, transactionStatus, collectionName)
# are aggregated per database by the query. Widgets are grouped in DBA-review
# order and preceded by a metric reference header.
# ---------------------------------------------------------------------------
locals {
  dashboard_name = var.dashboard_name_prefix != "" ? var.dashboard_name_prefix : "${var.vm_cluster_name}-CDB-Databases"

  cdb_where = "cloudVmClusterId = '${var.vm_cluster_id}' AND resourceType = 'CDB'"

  header_markdown = <<-EOT
    # ${var.vm_cluster_name} — All Container Databases
    Every widget below charts all CDBs on this VM cluster as separate series (Metrics Insights `GROUP BY resourceName`) from the `AWS/ODB` namespace. Grouped in DBA-review order: health, CPU & sessions, workload, I/O & memory, RAC global cache, storage/FRA, and objects & jobs.

    | Metric | Group | Description | Units |
    | --- | --- | --- | --- |
    | MonitoringStatus | Health | Whether metric collection is succeeding for the database. | Status |
    | MonitoringUserPasswordExpiration | Health | Days until the monitoring user's password expires. | Days |
    | CpuUtilization | CPU & Sessions | CPU used as a percent of the CPUs the DB may use (2× OCPUs). | Percent |
    | CpuCount | CPU & Sessions | Number of CPUs available. | Count |
    | DBTime | CPU & Sessions | Average Active Sessions (CPU + wait). | Sessions |
    | CPUTime | CPU & Sessions | CPU-time component of Average Active Sessions. | sec/sec |
    | Sessions | CPU & Sessions | Number of sessions. | Count |
    | Processes | CPU & Sessions | Number of processes. | Count |
    | ProcessLimitUtilization | CPU & Sessions | Processes as a percent of the limit. | Percent |
    | SessionLimitUtilization | CPU & Sessions | Sessions as a percent of the limit. | Percent |
    | CurrentLogons | CPU & Sessions | Successful logons during the interval. | Count |
    | TransactionCount | Workload | User commits + rollbacks. | Count |
    | TransactionsByStatus | Workload | Committed vs rolled-back transactions per second. | tx/sec |
    | ExecuteCount | Workload | Calls that executed SQL. | Count |
    | UserCalls | Workload | Logons + parses + execute calls. | Count |
    | ParseCount | Workload | Hard and soft parses. | Count |
    | ParsesByType | Workload | Hard vs soft parses per second. | parses/sec |
    | LogicalBlocksRead | Workload | Blocks read from buffer cache per second. | reads/sec |
    | BlockChanges | Workload | Blocks changed per second. | changes/sec |
    | RedoSize | Workload | Redo generated per second. | MB/sec |
    | RedoGenerationRate | Workload | Rate of redo generation. | MB/sec |
    | IOPS | I/O & Memory | I/O operations per second. | ops/sec |
    | IOThroughput | I/O & Memory | I/O throughput. | MB/sec |
    | WaitTime | I/O & Memory | Wait-time accumulation rate. | sec/sec |
    | MemoryUsage | I/O & Memory | Memory in use. | MB |
    | InterConnectTraffic | RAC Global Cache | RAC interconnect traffic. | MB/sec |
    | GCCRBlocksReceived | RAC Global Cache | GC CR blocks received per second. | blocks/sec |
    | GCCurrentBlocksReceived | RAC Global Cache | GC current blocks received per second. | blocks/sec |
    | AvgGCCRBlockReceiveTime | RAC Global Cache | Avg time to receive a GC CR block. | ms |
    | AvgGCCurrentBlockReceiveTime | RAC Global Cache | Avg time to receive a GC current block. | ms |
    | StorageUtilization | Storage & FRA | Provisioned storage capacity in use. | Percent |
    | StorageAllocated | Storage & FRA | Space allocated to the database. | GB |
    | StorageUsed | Storage & FRA | Space used by the database. | GB |
    | StorageUtilizationByTablespace | Storage & FRA | Space utilized (aggregated across tablespaces). | Percent |
    | StorageAllocatedByTablespace | Storage & FRA | Space allocated (aggregated across tablespaces). | GB |
    | StorageUsedByTablespace | Storage & FRA | Space used (aggregated across tablespaces). | GB |
    | AllocatedStorageUtilizationByTablespace | Storage & FRA | Allocated space utilized (aggregated across tablespaces). | Percent |
    | MaxTablespaceSize | Storage & FRA | Maximum tablespace size. | GB |
    | FRAUtilization | Storage & FRA | Flash Recovery Area utilization. | Percent |
    | UsableFRA | Storage & FRA | Usable Flash Recovery Area. | Percent |
    | UsedFRASpace | Storage & FRA | FRA space used. | GB |
    | ReclaimableFRA | Storage & FRA | Reclaimable FRA. | Percent |
    | ReclaimableFRASpace | Storage & FRA | Reclaimable FRA space. | GB |
    | NonReclaimableFRA | Storage & FRA | Non-reclaimable FRA. | Percent |
    | FRASpaceLimit | Storage & FRA | FRA space limit. | GB |
    | ProblematicScheduledDBMSJobs | Objects & Jobs | Count of failed/problematic scheduled DBMS jobs. | Count |
  EOT

  # Metric catalog in DBA-review order. `kind = "section"` emits a full-width
  # label; otherwise a GROUP BY resourceName widget (one series per CDB).
  widgets = [
    { kind = "section", title = "Health" },
    { metric = "MonitoringStatus", title = "Monitoring Status", stat = "MAX", period = 300, full_width = true },
    { metric = "MonitoringUserPasswordExpiration", title = "Monitoring User Password Expiration (days)", stat = "MIN", period = 3600, annotations = [{ label = "Warning", value = 7, color = "#ff7f0e" }, { label = "Critical", value = 3, color = "#d62728" }] },

    { kind = "section", title = "CPU & Sessions" },
    { metric = "CpuUtilization", title = "CPU Utilization (%)", stat = "MAX", period = 300, pct = true, annotations = [{ label = "Critical", value = 80, color = "#d62728" }] },
    { metric = "CpuCount", title = "CPU Count", stat = "MAX", period = 900 },
    { metric = "DBTime", title = "DB Time (Average Active Sessions)", stat = "AVG", period = 300 },
    { metric = "CPUTime", title = "CPU Time (sec/sec)", stat = "AVG", period = 300 },
    { metric = "Sessions", title = "Sessions", stat = "AVG", period = 300 },
    { metric = "Processes", title = "Process Count", stat = "MAX", period = 300 },
    { metric = "ProcessLimitUtilization", title = "Process Limit Utilization (%)", stat = "AVG", period = 300, pct = true, annotations = [{ label = "Critical", value = 80, color = "#d62728" }] },
    { metric = "SessionLimitUtilization", title = "Session Limit Utilization (%)", stat = "AVG", period = 300, pct = true, annotations = [{ label = "Critical", value = 80, color = "#d62728" }] },
    { metric = "CurrentLogons", title = "Current Logons", stat = "AVG", period = 300 },

    { kind = "section", title = "Workload" },
    { metric = "TransactionCount", title = "Transaction Count", stat = "AVG", period = 300 },
    { metric = "TransactionsByStatus", title = "Transactions By Status (tx/sec)", stat = "AVG", period = 300 },
    { metric = "ExecuteCount", title = "Execute Count", stat = "AVG", period = 300 },
    { metric = "UserCalls", title = "User Calls", stat = "AVG", period = 300 },
    { metric = "ParseCount", title = "Parse Count", stat = "AVG", period = 300 },
    { metric = "ParsesByType", title = "Parses By Type (parses/sec)", stat = "AVG", period = 300 },
    { metric = "LogicalBlocksRead", title = "Logical Reads (reads/sec)", stat = "AVG", period = 300 },
    { metric = "BlockChanges", title = "Block Changes (changes/sec)", stat = "AVG", period = 300 },
    { metric = "RedoSize", title = "Redo Generated (MB/sec)", stat = "AVG", period = 300 },
    { metric = "RedoGenerationRate", title = "Redo Generation Rate (MB/sec)", stat = "AVG", period = 300 },

    { kind = "section", title = "I/O & Memory" },
    { metric = "IOPS", title = "IOPS (ops/sec)", stat = "AVG", period = 300 },
    { metric = "IOThroughput", title = "IO Throughput (MB/sec)", stat = "AVG", period = 300 },
    { metric = "WaitTime", title = "Wait Time (sec/sec)", stat = "AVG", period = 300 },
    { metric = "MemoryUsage", title = "Memory Usage (MB)", stat = "AVG", period = 900 },

    { kind = "section", title = "RAC Global Cache" },
    { metric = "InterConnectTraffic", title = "Interconnect Traffic (MB/sec)", stat = "AVG", period = 300 },
    { metric = "GCCRBlocksReceived", title = "GC CR Blocks Received (blocks/sec)", stat = "AVG", period = 300 },
    { metric = "GCCurrentBlocksReceived", title = "GC Current Blocks Received (blocks/sec)", stat = "AVG", period = 300 },
    { metric = "AvgGCCRBlockReceiveTime", title = "Avg GC CR Block Receive Time (ms)", stat = "AVG", period = 300 },
    { metric = "AvgGCCurrentBlockReceiveTime", title = "Avg GC Current Block Receive Time (ms)", stat = "AVG", period = 300 },

    { kind = "section", title = "Storage & Flash Recovery Area" },
    { metric = "StorageUtilization", title = "Storage Utilization (%)", stat = "MAX", period = 3600, pct = true, annotations = [{ label = "Warning", value = 85, color = "#ff7f0e" }, { label = "Critical", value = 90, color = "#d62728" }] },
    { metric = "StorageAllocated", title = "Storage Allocated (GB)", stat = "MAX", period = 3600 },
    { metric = "StorageUsed", title = "Storage Used (GB)", stat = "MAX", period = 3600 },
    { metric = "StorageUtilizationByTablespace", title = "Tablespace Utilization (%, max across tablespaces)", stat = "MAX", period = 3600, pct = true, annotations = [{ label = "Warning", value = 85, color = "#ff7f0e" }, { label = "Critical", value = 90, color = "#d62728" }] },
    { metric = "StorageAllocatedByTablespace", title = "Tablespace Allocated (GB, sum across tablespaces)", stat = "MAX", period = 3600 },
    { metric = "StorageUsedByTablespace", title = "Tablespace Used (GB, sum across tablespaces)", stat = "MAX", period = 3600 },
    { metric = "AllocatedStorageUtilizationByTablespace", title = "Allocated Tablespace Utilization (%, max across tablespaces)", stat = "MAX", period = 3600, pct = true },
    { metric = "MaxTablespaceSize", title = "Max Tablespace Size (GB)", stat = "MAX", period = 1800 },
    { metric = "FRAUtilization", title = "Flash Recovery Area Utilization (%)", stat = "AVG", period = 900, pct = true, annotations = [{ label = "Warning", value = 80, color = "#ff7f0e" }, { label = "Critical", value = 90, color = "#d62728" }] },
    { metric = "UsableFRA", title = "Usable Flash Recovery Area (%)", stat = "AVG", period = 900, pct = true },
    { metric = "UsedFRASpace", title = "Flash Recovery Area Usage (GB)", stat = "MAX", period = 900 },
    { metric = "ReclaimableFRA", title = "Reclaimable Flash Recovery Area (%)", stat = "AVG", period = 900, pct = true },
    { metric = "ReclaimableFRASpace", title = "Reclaimable Flash Recovery Area (GB)", stat = "AVG", period = 900 },
    { metric = "NonReclaimableFRA", title = "Non-Reclaimable Flash Recovery Area (%)", stat = "AVG", period = 900, pct = true },
    { metric = "FRASpaceLimit", title = "Flash Recovery Area Space Limit (GB)", stat = "MAX", period = 900 },

    { kind = "section", title = "Objects & Jobs" },
    # ProblematicScheduledDBMSJobs has no resourceType dimension (keyed by
    # resourceName + type), so it needs a SCHEMA() query rather than the
    # standard resourceType='CDB' filter.
    { metric = "ProblematicScheduledDBMSJobs", title = "Problematic Scheduled DBMS Jobs", stat = "MAX", period = 900, expr = "SELECT MAX(ProblematicScheduledDBMSJobs) FROM SCHEMA(\"AWS/ODB\", cloudExadataInfrastructureId,cloudVmClusterId,deploymentType,ociCloudExadataInfrastructureId,ociCloudVmClusterId,resourceId,resourceName,type) WHERE cloudVmClusterId = '${var.vm_cluster_id}' GROUP BY resourceName" },
  ]
}

resource "aws_cloudwatch_dashboard" "cdb_dashboard" {
  dashboard_name = local.dashboard_name

  # Each widget is jsonencode()'d individually then jsondecode'd in the outer
  # list so the heterogeneous text/section/metric shapes unify to one list type.
  # x/y omitted: CloudWatch auto-flows widgets left-to-right, wrapping by width.
  dashboard_body = jsonencode({
    widgets = [
      for s in concat(
        [
          jsonencode({
            type       = "text"
            width      = 24
            height     = 8
            properties = { markdown = local.header_markdown }
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
                  title   = w.title
                  region  = "us-east-1"
                  view    = "timeSeries"
                  stacked = false
                  period  = w.period
                  metrics = [
                    [{
                      # A widget may supply a custom `expr` (used verbatim) for
                      # metrics that don't carry the resourceType='CDB'
                      # dimension; otherwise the standard per-CDB query is built.
                      expression = lookup(w, "expr", "") != "" ? w.expr : "SELECT ${w.stat}(${w.metric}) FROM \"AWS/ODB\" WHERE ${local.cdb_where} GROUP BY resourceName"
                      label      = w.metric
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
