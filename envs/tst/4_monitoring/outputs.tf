# =========================================================================
# Outputs from 4_monitoring stage
# =========================================================================
# This stage primarily creates resources but does not expose significant outputs,
# as monitoring alarms are infrastructure management tools.

output "cloudwatch_cluster_monitoring_id" {
  description = "CloudWatch cluster monitoring module outputs"
  value       = module.cloudwatch_cluster_monitoring
}

output "cloudwatch_db_server_monitoring_id" {
  description = "CloudWatch DB server monitoring module outputs"
  value       = module.cloudwatch_db_server_monitoring
}

output "cdb_monitoring_modules" {
  description = "Map of CDB monitoring module identifiers"
  value = {
    cloudwatch_cdb_ids = [for k, v in module.cloudwatch_cdb_monitoring : k]
    ocimon_cdb_ids     = [for k, v in module.ocimon_cdb_monitoring : k]
  }
}

output "pdb_monitoring_modules" {
  description = "Map of PDB monitoring module identifiers"
  value = {
    cloudwatch_pdb_ids = [for k, v in module.cloudwatch_pdb_monitoring : k]
    ocimon_pdb_ids     = [for k, v in module.ocimon_pdb_monitoring : k]
  }
}

