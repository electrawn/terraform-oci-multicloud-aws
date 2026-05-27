
module "pdb" {
  source                  = "../oci-db-pdb"
  container_database_ocid = var.container_database_ocid
  pdb_name                = var.pdb_name
  pdb_admin_password      = var.pdb_admin_password
  pdb_tde_wallet_password = var.pdb_tde_wallet_password
  tags                    = var.tags

}

locals {
  service_name = split("/", module.pdb.oci_resource.connection_strings[0].pdb_default)
}


resource "oci_database_pluggable_database_pluggabledatabasemanagements_management" "pdb_management" {

  private_end_point_id = var.private_end_point_ocid
  service_name         = local.service_name[1]
  credential_details {
    password_secret_id = var.db_management_password_ocid
    user_name          = "dbsnmp"
  }
  enable_pluggabledatabasemanagement = true
  pluggable_database_id              = module.pdb.oci_resource_ocid
  lifecycle {
    ignore_changes = [
      connection_strings, pluggable_database_management_config, defined_tags, freeform_tags
    ]
  }

}


module "cloudwatch_monitor" {
  source     = "../cloudwatch/pdb_monitoring"
  depends_on = [module.pdb]

  exainfra_id     = var.exainfra_id
  exainfra_ocid   = var.exainfra_ocid
  vm_cluster_id   = var.vm_cluster_id
  vm_cluster_name = var.vm_cluster_name
  vm_cluster_ocid = var.vm_cluster_ocid
  database_name   = module.pdb.oci_resource.pdb_name
  database_ocid   = module.pdb.oci_resource_ocid
  environment     = var.environment
  tags            = var.tags
  in_downtime     = var.in_downtime
  sns_alert_arn   = var.sns_alert_arn
  alarms_enabled  = var.alarms_enabled
}


module "ocimon_monitor" {
  source     = "../ocimon/pdb_monitoring"
  depends_on = [module.pdb]

  compartment_ocid = module.pdb.oci_resource.compartment_id
  destinations     = [var.notification_topic_ocid]
  exainfra_id      = var.exainfra_id
  exainfra_ocid    = var.exainfra_ocid
  vm_cluster_id    = var.vm_cluster_id
  vm_cluster_name  = var.vm_cluster_name
  vm_cluster_ocid  = var.vm_cluster_ocid
  database_name    = module.pdb.oci_resource.pdb_name
  database_ocid    = module.pdb.oci_resource_ocid
  environment      = var.environment
  tags             = var.tags
  in_downtime      = var.in_downtime
  alarms_enabled   = false
}