# ---------------------------------------------------------------------------
# ALL PDB Databases dashboard (one per VM cluster).
#
# Each widget charts every PDB on the cluster as a separate series using a
# CloudWatch Metrics Insights query:
#   SELECT <stat>(<metric>) FROM "AWS/ODB"
#   WHERE cloudVmClusterId = '<vmc>' AND resourceType = 'PDB'
#   GROUP BY resourceName
# GROUP BY resourceName produces one line per PDB and auto-discovers every PDB
# on the cluster. Metrics with extra dimensions (tablespace, parseType,
# transactionStatus, collectionName) are aggregated per PDB by the query.
# Widgets are grouped in DBA-review order and preceded by a metric reference
# header.
# ---------------------------------------------------------------------------
locals {
  dashboard_name = var.dashboard_name_prefix != "" ? var.dashboard_name_prefix : "${var.vm_cluster_name}-PDB-Databases"

  pdb_where = "cloudVmClusterId = '${var.vm_cluster_id}' AND resourceType = 'PDB'"

  header_markdown = <<-EOT
    # ${var.vm_cluster_name} — All Pluggable Databases
    Every widget below charts all PDBs on this VM cluster as separate series (Metrics Insights `GROUP BY resourceName`) from the `AWS/ODB` namespace. Grouped in DBA-review order: health, CPU & sessions, workload, I/O & memory, storage & tablespaces, and objects.

    | Metric | Group | Description | Units |
    | --- | --- | --- | --- |
    | MonitoringStatus | Health | Whether metric collection is succeeding for the database. | Status |
    | MonitoringUserPasswordExpiration | Health | Days until the monitoring user's password expires. | Days |
    | CpuUtilization | CPU & Sessions | CPU used as a percent of the CPUs the DB may use (2× OCPUs). | Percent |
    | CpuCount | CPU & Sessions | Number of CPUs available. | Count |
    | DBTime | CPU & Sessions | Average Active Sessions (CPU + wait). | Sessions |
    | CPUTime | CPU & Sessions | CPU-time component of Average Active Sessions. | sec/sec |
    | Sessions | CPU & Sessions | Number of sessions. | Count |
    | CurrentLogons | CPU & Sessions | Successful logons during the interval. | Count |
    | BlockingSessions | CPU & Sessions | Sessions currently blocking other sessions. | Count |
    | TransactionCount | Workload | User commits + rollbacks. | Count |
    | TransactionsByStatus | Workload | Committed vs rolled-back transactions per second. | tx/sec |
    | ExecuteCount | Workload | Calls that executed SQL. | Count |
    | UserCalls | Workload | Logons + parses + execute calls. | Count |
    | ParseCount | Workload | Hard and soft parses. | Count |
    | ParsesByType | Workload | Hard vs soft parses per second. | parses/sec |
    | LogicalBlocksRead | Workload | Blocks read from buffer cache per second. | reads/sec |
    | BlockChanges | Workload | Blocks changed per second. | changes/sec |
    | RedoSize | Workload | Redo generated per second. | MB/sec |
    | IOPS | I/O & Memory | I/O operations per second. | ops/sec |
    | IOThroughput | I/O & Memory | I/O throughput. | MB/sec |
    | WaitTime | I/O & Memory | Wait-time accumulation rate. | sec/sec |
    | MemoryUsage | I/O & Memory | Memory in use. | MB |
    | StorageUtilization | Storage | Provisioned storage capacity in use. | Percent |
    | StorageAllocated | Storage | Space allocated to the database. | GB |
    | StorageUsed | Storage | Space used by the database. | GB |
    | StorageUtilizationByTablespace | Storage | Space utilized (aggregated across tablespaces). | Percent |
    | StorageAllocatedByTablespace | Storage | Space allocated (aggregated across tablespaces). | GB |
    | StorageUsedByTablespace | Storage | Space used (aggregated across tablespaces). | GB |
    | MaxTablespaceSize | Storage | Maximum tablespace size. | GB |
    | InvalidObjects | Objects | Count of invalid database objects. | Count |
  EOT

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
    { metric = "CurrentLogons", title = "Current Logons", stat = "AVG", period = 300 },
    { metric = "BlockingSessions", title = "Blocking Sessions", stat = "MAX", period = 300, annotations = [{ label = "Investigate", value = 1, color = "#ff7f0e" }] },

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

    { kind = "section", title = "I/O & Memory" },
    { metric = "IOPS", title = "IOPS (ops/sec)", stat = "AVG", period = 300 },
    { metric = "IOThroughput", title = "IO Throughput (MB/sec)", stat = "AVG", period = 300 },
    { metric = "WaitTime", title = "Wait Time (sec/sec)", stat = "AVG", period = 300 },
    { metric = "MemoryUsage", title = "Memory Usage (MB)", stat = "AVG", period = 900 },

    { kind = "section", title = "Storage & Tablespaces" },
    { metric = "StorageUtilization", title = "Storage Utilization (%)", stat = "MAX", period = 3600, pct = true, annotations = [{ label = "Warning", value = 85, color = "#ff7f0e" }, { label = "Critical", value = 90, color = "#d62728" }] },
    { metric = "StorageAllocated", title = "Storage Allocated (GB)", stat = "MAX", period = 3600 },
    { metric = "StorageUsed", title = "Storage Used (GB)", stat = "MAX", period = 3600 },
    { metric = "StorageUtilizationByTablespace", title = "Tablespace Utilization (%, max across tablespaces)", stat = "MAX", period = 3600, pct = true, annotations = [{ label = "Warning", value = 85, color = "#ff7f0e" }, { label = "Critical", value = 90, color = "#d62728" }] },
    { metric = "StorageAllocatedByTablespace", title = "Tablespace Allocated (GB, sum across tablespaces)", stat = "MAX", period = 3600 },
    { metric = "StorageUsedByTablespace", title = "Tablespace Used (GB, sum across tablespaces)", stat = "MAX", period = 3600 },
    { metric = "MaxTablespaceSize", title = "Max Tablespace Size (GB)", stat = "MAX", period = 1800 },

    { kind = "section", title = "Objects" },
    { metric = "InvalidObjects", title = "Invalid Objects", stat = "MAX", period = 86400 },
  ]
}

resource "aws_cloudwatch_dashboard" "pdb_dashboard" {
  dashboard_name = local.dashboard_name

  # Each widget is jsonencode()'d individually then jsondecode'd in the outer
  # list so the heterogeneous text/section/metric shapes unify to one list type.
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
                      expression = "SELECT ${w.stat}(${w.metric}) FROM \"AWS/ODB\" WHERE ${local.pdb_where} GROUP BY resourceName"
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
