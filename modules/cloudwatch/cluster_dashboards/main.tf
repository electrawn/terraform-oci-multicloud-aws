# ---------------------------------------------------------------------------
# VM Cluster CloudWatch dashboards.
#
# Two kinds of dashboard are produced from the AWS/ODB namespace:
#
#   1. "<cluster>-VMCluster"            — cluster-wide view: ASM disk group
#      utilization, OCPU allocation, and node-level OS metrics aggregated across
#      every DB node (one series per node via Metrics Insights GROUP BY hostName).
#
#   2. "<cluster>-VMCluster-<n>"        — one dashboard per DB node, charting
#      that node's OS metrics filtered by resourceName_dbnode (the node hostname).
#
# All widgets use CloudWatch Metrics Insights SELECT ... FROM SCHEMA(...) so the
# exact published dimension set is matched (a partial dimension list returns no
# data). Metric names, casing, and dimensions were verified against the live
# AWS/ODB metric stream and the cluster_monitoring / db_server_monitoring alarm
# modules:
#   - cluster level : ASMDiskgroupUtilization (per diskgroupName), OcpusAllocated
#   - node level    : CpuUtilization, MemoryUtilization, LoadAverage,
#                     SwapUtilization, NodeStatus, FilesystemUtilization
# Node OS metric names are Cpu/Memory (not CPU/MEMORY); deploymentType is the
# lowercase literal "exadata".
# ---------------------------------------------------------------------------

data "aws_odb_cloud_vm_cluster" "vm_cluster" {
  id = var.vm_cluster_id
}

data "aws_odb_cloud_exadata_infrastructure" "exainfra" {
  id = var.exainfra_id
}

data "aws_odb_db_nodes" "db_nodes" {
  cloud_vm_cluster_id = var.vm_cluster_id
}

locals {
  cluster_name = data.aws_odb_cloud_vm_cluster.vm_cluster.cluster_name
  base_name    = var.dashboard_name_prefix != "" ? var.dashboard_name_prefix : local.cluster_name

  # DB nodes keyed by hostname, then numbered 1..N in sorted hostname order so
  # node numbering is stable across runs.
  node_by_hostname = {
    for n in data.aws_odb_db_nodes.db_nodes.db_nodes : n.hostname => n
  }
  sorted_hostnames = sort(keys(local.node_by_hostname))
  nodes_by_number = {
    for idx, hn in local.sorted_hostnames : tostring(idx + 1) => local.node_by_hostname[hn]
  }

  # Exact published dimension key sets (order-independent for SCHEMA()).
  asm_schema    = "cloudExadataInfrastructureId,cloudVmClusterId,deploymentType,diskgroupName,ociCloudExadataInfrastructureId,ociCloudVmClusterId,resourceId,resourceName"
  ocpu_schema   = "cloudExadataInfrastructureId,cloudVmClusterId,deploymentType,ociCloudExadataInfrastructureId,ociCloudVmClusterId,resourceId,resourceName"
  node_schema   = "cloudExadataInfrastructureId,cloudVmClusterId,deploymentType,hostName,ociCloudExadataInfrastructureId,ociCloudVmClusterId,resourceId,resourceId_dbnode,resourceName,resourceName_dbnode"
  nodefs_schema = "cloudExadataInfrastructureId,cloudVmClusterId,deploymentType,filesystemName,hostName,ociCloudExadataInfrastructureId,ociCloudVmClusterId,resourceId,resourceId_dbnode,resourceName,resourceName_dbnode"

  # --- cluster dashboard -------------------------------------------------
  cluster_header = <<-EOT
    # ${local.cluster_name} — VM Cluster
    Cluster-wide view from the `AWS/ODB` namespace. ASM and OCPU widgets are cluster-scoped; node OS widgets chart every DB node as a separate series (Metrics Insights `GROUP BY hostName`). Per-node dashboards are published separately as `${local.base_name}-VMCluster-<n>`.

    | Metric | Group | Description | Units |
    | --- | --- | --- | --- |
    | ASMDiskgroupUtilization | Storage (ASM) | Percentage of the DATA / RECO ASM disk group in use. | Percent |
    | OcpusAllocated | Storage (ASM) | OCPUs allocated to the VM cluster. | Count |
    | NodeStatus | Node OS | Node reachability (1 = reachable, 0 = unreachable). | Status |
    | CpuUtilization | Node OS | Host CPU used as a percent of available CPU. | Percent |
    | MemoryUtilization | Node OS | Host memory in use. | Percent |
    | LoadAverage | Node OS | Host run-queue load average. | Load |
    | SwapUtilization | Node OS | Host swap space in use. | Percent |
    | FilesystemUtilization | Node OS | Local filesystem usage (max across mount points). | Percent |
  EOT

  cluster_widgets = [
    { kind = "section", title = "Storage (ASM)" },
    { metric = "ASMDiskgroupUtilization", title = "ASM Diskgroup Utilization (%) — per diskgroup", stat = "MAX", period = 900, schema = local.asm_schema, where = "cloudVmClusterId = '${var.vm_cluster_id}'", group = "diskgroupName", pct = true, annotations = [{ label = "Warning", value = 75, color = "#ff7f0e" }, { label = "Critical", value = 85, color = "#d62728" }] },
    { metric = "OcpusAllocated", title = "OCPUs Allocated", stat = "MAX", period = 900, schema = local.ocpu_schema, where = "cloudVmClusterId = '${var.vm_cluster_id}'", group = "" },

    { kind = "section", title = "Node OS (per node)" },
    { metric = "NodeStatus", title = "Node Status (1 = reachable) — per node", stat = "MIN", period = 300, schema = local.node_schema, where = "cloudVmClusterId = '${var.vm_cluster_id}'", group = "hostName", annotations = [{ label = "Unreachable", value = 1, color = "#d62728" }] },
    { metric = "CpuUtilization", title = "CPU Utilization (%) — per node", stat = "MAX", period = 300, schema = local.node_schema, where = "cloudVmClusterId = '${var.vm_cluster_id}'", group = "hostName", pct = true, annotations = [{ label = "Warning", value = 90, color = "#ff7f0e" }, { label = "Critical", value = 95, color = "#d62728" }] },
    { metric = "MemoryUtilization", title = "Memory Utilization (%) — per node", stat = "MAX", period = 300, schema = local.node_schema, where = "cloudVmClusterId = '${var.vm_cluster_id}'", group = "hostName", pct = true, annotations = [{ label = "Critical", value = 90, color = "#d62728" }] },
    { metric = "LoadAverage", title = "Load Average — per node", stat = "MAX", period = 300, schema = local.node_schema, where = "cloudVmClusterId = '${var.vm_cluster_id}'", group = "hostName" },
    { metric = "SwapUtilization", title = "Swap Utilization (%) — per node", stat = "MAX", period = 300, schema = local.node_schema, where = "cloudVmClusterId = '${var.vm_cluster_id}'", group = "hostName", pct = true },
    { metric = "FilesystemUtilization", title = "Filesystem Utilization (%) — max across mounts, per node", stat = "MAX", period = 300, schema = local.nodefs_schema, where = "cloudVmClusterId = '${var.vm_cluster_id}'", group = "hostName", pct = true, annotations = [{ label = "Warning", value = 85, color = "#ff7f0e" }, { label = "Critical", value = 90, color = "#d62728" }] },
  ]
}

# ---------------------------------------------------------------------------
# Cluster-wide dashboard.
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "cluster_dashboard" {
  dashboard_name = "${local.base_name}-VMCluster"

  dashboard_body = jsonencode({
    widgets = [
      for s in concat(
        [
          jsonencode({
            type       = "text"
            width      = 24
            height     = 6
            properties = { markdown = local.cluster_header }
          })
        ],
        [
          for w in local.cluster_widgets : (
            lookup(w, "kind", "metric") == "section"
            ? jsonencode({
              type       = "text"
              width      = 24
              height     = 1
              properties = { markdown = "## ${w.title}" }
            })
            : jsonencode({
              type   = "metric"
              width  = 12
              height = 6
              properties = merge(
                {
                  title   = w.title
                  region  = var.region
                  view    = "timeSeries"
                  stacked = false
                  period  = w.period
                  metrics = [
                    [{
                      expression = w.group != "" ? "SELECT ${w.stat}(${w.metric}) FROM SCHEMA(\"AWS/ODB\", ${w.schema}) WHERE ${w.where} GROUP BY ${w.group}" : "SELECT ${w.stat}(${w.metric}) FROM SCHEMA(\"AWS/ODB\", ${w.schema}) WHERE ${w.where}"
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

# ---------------------------------------------------------------------------
# Per-node dashboards: "<cluster>-VMCluster-<n>".
# Filtered to a single node by resourceName_dbnode (= node hostname).
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "node_dashboard" {
  for_each = local.nodes_by_number

  dashboard_name = "${local.base_name}-VMCluster-${each.key}"

  dashboard_body = jsonencode({
    widgets = [
      for s in concat(
        [
          jsonencode({
            type   = "text"
            width  = 24
            height = 6
            properties = {
              markdown = <<-EOT
                # ${local.cluster_name} — VM Cluster Node ${each.key}
                Host: `${each.value.hostname}` · DB server: `${each.value.db_server_id}`

                Node-level OS metrics from the `AWS/ODB` namespace, filtered to this node (`resourceName_dbnode`).

                | Metric | Group | Description | Units |
                | --- | --- | --- | --- |
                | NodeStatus | Node OS | Node reachability (1 = reachable, 0 = unreachable). | Status |
                | CpuUtilization | Node OS | Host CPU used as a percent of available CPU. | Percent |
                | MemoryUtilization | Node OS | Host memory in use. | Percent |
                | LoadAverage | Node OS | Host run-queue load average. | Load |
                | SwapUtilization | Node OS | Host swap space in use. | Percent |
                | FilesystemUtilization | Filesystems | Usage per mount point. | Percent |
              EOT
            }
          })
        ],
        [
          for w in [
            { kind = "section", title = "Node OS" },
            { metric = "NodeStatus", title = "Node Status (1 = reachable)", stat = "MIN", period = 300, schema = local.node_schema, group = "", annotations = [{ label = "Unreachable", value = 1, color = "#d62728" }] },
            { metric = "CpuUtilization", title = "CPU Utilization (%)", stat = "MAX", period = 300, schema = local.node_schema, group = "", pct = true, annotations = [{ label = "Warning", value = 90, color = "#ff7f0e" }, { label = "Critical", value = 95, color = "#d62728" }] },
            { metric = "MemoryUtilization", title = "Memory Utilization (%)", stat = "MAX", period = 300, schema = local.node_schema, group = "", pct = true, annotations = [{ label = "Critical", value = 90, color = "#d62728" }] },
            { metric = "LoadAverage", title = "Load Average", stat = "MAX", period = 300, schema = local.node_schema, group = "" },
            { metric = "SwapUtilization", title = "Swap Utilization (%)", stat = "MAX", period = 300, schema = local.node_schema, group = "", pct = true },
            { kind = "section", title = "Filesystems" },
            { metric = "FilesystemUtilization", title = "Filesystem Utilization (%) — per mount", stat = "MAX", period = 300, schema = local.nodefs_schema, group = "filesystemName", pct = true, full_width = true, annotations = [{ label = "Warning", value = 85, color = "#ff7f0e" }, { label = "Critical", value = 90, color = "#d62728" }] },
            ] : (
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
                  region  = var.region
                  view    = "timeSeries"
                  stacked = false
                  period  = w.period
                  metrics = [
                    [{
                      expression = w.group != "" ? "SELECT ${w.stat}(${w.metric}) FROM SCHEMA(\"AWS/ODB\", ${w.schema}) WHERE resourceName_dbnode = '${each.value.hostname}' GROUP BY ${w.group}" : "SELECT ${w.stat}(${w.metric}) FROM SCHEMA(\"AWS/ODB\", ${w.schema}) WHERE resourceName_dbnode = '${each.value.hostname}'"
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
