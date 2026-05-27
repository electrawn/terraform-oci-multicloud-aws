
module "cdb" {
  source            = "../oci-db-cdb"
  exa_db_home_ocid  = var.db_home_ocid
  db_name           = var.cdb_name
  db_admin_password = var.cdb_admin_password
  db_source         = var.cdb_source

  auto_backup             = var.cdb_auto_backup_enabled
  auto_backup_window      = var.auto_backup_window      #"SLOT_FIVE"
  auto_full_backup_day    = var.auto_full_backup_day    #"MONDAY"
  auto_full_backup_window = var.auto_full_backup_window # "SLOT_FIVE"
  backup_deletion_policy  = var.backup_deletion_policy  #"DELETE_AFTER_RETENTION_PERIOD"
  backup_destination_type = var.backup_destination_type #"OBJECT_STORE"

  recovery_window_in_days   = var.recovery_window_in_days   #"7"
  run_immediate_full_backup = var.run_immediate_full_backup #"true"
  tags                      = var.tags

}

locals {

  service_name = split("/", module.cdb.oci_resource.connection_strings[0].cdb_default)
}


resource "oci_database_cloud_database_management" "cdb_management" {
  database_id          = module.cdb.oci_resource_ocid
  private_end_point_id = var.private_end_point_ocid
  service_name         = local.service_name[1] #["cdb_default"]
  management_type      = "ADVANCED"
  credentialdetails {
    password_secret_id = var.db_management_password_ocid
    user_name          = "dbsnmp"
  }
  enable_management = true
}

module "cloudwatch_monitor" {
  source     = "../cloudwatch/cdb_monitoring"
  depends_on = [module.cdb]

  exainfra_id     = var.exainfra_id
  exainfra_ocid   = var.exainfra_ocid
  vm_cluster_id   = var.vm_cluster_id
  vm_cluster_name = var.vm_cluster_name
  vm_cluster_ocid = var.vm_cluster_ocid
  database_name   = module.cdb.oci_resource.db_name
  database_ocid   = module.cdb.oci_resource_ocid
  environment     = var.environment
  tags            = var.tags
  in_downtime     = var.in_downtime
  sns_alert_arn   = var.sns_alert_arn
  alarms_enabled  = var.alarms_enabled
}

module "ocimon_monitor" {
  source     = "../ocimon/cdb_monitoring"
  depends_on = [module.cdb]

  compartment_ocid = module.cdb.oci_resource.compartment_id
  destinations     = [var.notification_topic_ocid]
  exainfra_id      = var.exainfra_id
  exainfra_ocid    = var.exainfra_ocid
  vm_cluster_id    = var.vm_cluster_id
  vm_cluster_name  = var.vm_cluster_name
  vm_cluster_ocid  = var.vm_cluster_ocid
  database_name    = module.cdb.oci_resource.db_name
  database_ocid    = module.cdb.oci_resource_ocid
  environment      = var.environment
  tags             = var.tags
  in_downtime      = var.in_downtime
  alarms_enabled   = false
}

