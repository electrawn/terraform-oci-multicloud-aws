# =========================================================================
# Outputs from 4_monitoring stage
# =========================================================================

output "cdb_monitoring_modules" {
  description = "Map of CDB monitoring module identifiers per cluster"
  value = {
    exa1_cloudwatch_cdb_ids = [for k, v in module.cloudwatch_cdb_monitoring_exa1 : k]
    exa2_cloudwatch_cdb_ids = [for k, v in module.cloudwatch_cdb_monitoring_exa2 : k]
    exa3_cloudwatch_cdb_ids = [for k, v in module.cloudwatch_cdb_monitoring_exa3 : k]
    exa1_ocimon_cdb_ids     = [for k, v in module.ocimon_cdb_monitoring_exa1 : k]
    exa2_ocimon_cdb_ids     = [for k, v in module.ocimon_cdb_monitoring_exa2 : k]
    exa3_ocimon_cdb_ids     = [for k, v in module.ocimon_cdb_monitoring_exa3 : k]
  }
}

output "pdb_monitoring_modules" {
  description = "Map of PDB monitoring module identifiers per cluster"
  value = {
    exa1_cloudwatch_pdb_ids = [for k, v in module.cloudwatch_pdb_monitoring_exa1 : k]
    exa2_cloudwatch_pdb_ids = [for k, v in module.cloudwatch_pdb_monitoring_exa2 : k]
    exa3_cloudwatch_pdb_ids = [for k, v in module.cloudwatch_pdb_monitoring_exa3 : k]
    exa1_ocimon_pdb_ids     = [for k, v in module.ocimon_pdb_monitoring_exa1 : k]
    exa2_ocimon_pdb_ids     = [for k, v in module.ocimon_pdb_monitoring_exa2 : k]
    exa3_ocimon_pdb_ids     = [for k, v in module.ocimon_pdb_monitoring_exa3 : k]
  }
}
