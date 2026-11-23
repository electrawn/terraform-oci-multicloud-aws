locals {
  db_server_ids = try([for s in var.db_servers.db_servers : s.id], try([for s in var.db_servers : s.id], []))

  enable_db_server_monitoring = var.enable_monitoring_stage && var.db_servers != null && var.db_nodes != null && length(local.db_server_ids) > 0
}

module "cloudwatch_cluster_monitoring" {
  count = var.enable_monitoring_stage ? 1 : 0

  source             = "../../../../modules/cloudwatch/cluster_monitoring"
  exainfra_id        = var.exainfra_id
  vm_cluster_id      = var.vm_cluster_id
  environment        = var.environment
  opsgenie_alert_arn = var.opsgenie_alert_arn
  in_downtime        = var.in_downtime
  support_category   = var.support_category
  support_teams      = var.support_teams
}

# CloudWatch DB Server monitoring — DISABLED (too many per-node filesystem alarms)
# Uncomment when targeted node-level monitoring is needed.

output "cluster_monitoring_created" {
  value = length(module.cloudwatch_cluster_monitoring) > 0
}

output "db_server_monitoring_created" {
  value = false
}

