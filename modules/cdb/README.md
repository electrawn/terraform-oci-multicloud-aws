# cdb
This module provisions a Container Database (CDB) and wires CloudWatch and OCI monitoring modules.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_cdb"></a> [cdb](#module\_cdb) | ../oci-db-cdb | n/a |
| <a name="module_cloudwatch_monitor"></a> [cloudwatch\_monitor](#module\_cloudwatch\_monitor) | ../cloudwatch/cdb_monitoring | n/a |
| <a name="module_ocimon_monitor"></a> [ocimon\_monitor](#module\_ocimon\_monitor) | ../ocimon/cdb_monitoring | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [oci_database_cloud_database_management.cdb_management](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_cloud_database_management) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarms_enabled"></a> [alarms\_enabled](#input\_alarms\_enabled) | Master switch to enable or disable CloudWatch alarms | `bool` | `true` | no |
| <a name="input_auto_backup_window"></a> [auto\_backup\_window](#input\_auto\_backup\_window) | The 2-hour window selected for initiating automatic backups. Must be an enum value (e.g., SLOT\_ONE, SLOT\_TWO). | `string` | `"SLOT_TWO"` | no |
| <a name="input_auto_full_backup_day"></a> [auto\_full\_backup\_day](#input\_auto\_full\_backup\_day) | The day of the week the full backup should be performed. Must be one of the specified ENUM values. | `string` | `"SUNDAY"` | no |
| <a name="input_auto_full_backup_window"></a> [auto\_full\_backup\_window](#input\_auto\_full\_backup\_window) | The 2-hour window selected for initiating automatic backups. Must be an enum value (e.g., SLOT\_ONE, SLOT\_TWO). | `string` | `"SLOT_TWO"` | no |
| <a name="input_backup_deletion_policy"></a> [backup\_deletion\_policy](#input\_backup\_deletion\_policy) | Determines if backups are kept or deleted when the DB system is terminated. | `string` | `"DELETE_AFTER_RETENTION_PERIOD"` | no |
| <a name="input_backup_destination_type"></a> [backup\_destination\_type](#input\_backup\_destination\_type) | Type of backup destination. Typically 'OBJECT\_STORE' or 'RECOVERY\_SERVICE'. | `string` | `"OBJECT_STORE"` | no |
| <a name="input_cdb_admin_password"></a> [cdb\_admin\_password](#input\_cdb\_admin\_password) | A strong password for SYS, SYSTEM, PDB Admin and TDE Wallet. (required) | `string` | n/a | yes |
| <a name="input_cdb_auto_backup_enabled"></a> [cdb\_auto\_backup\_enabled](#input\_cdb\_auto\_backup\_enabled) | Enable automatic backup (optional), default false | `bool` | `false` | no |
| <a name="input_cdb_name"></a> [cdb\_name](#input\_cdb\_name) | The display name of the database. (required) | `string` | n/a | yes |
| <a name="input_cdb_source"></a> [cdb\_source](#input\_cdb\_source) | The source of the database (optional), default NONE. | `string` | `"NONE"` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | OCID for compartment | `string` | n/a | yes |
| <a name="input_db_home_ocid"></a> [db\_home\_ocid](#input\_db\_home\_ocid) | OCI Database DB Home OCID | `string` | n/a | yes |
| <a name="input_db_management_password_ocid"></a> [db\_management\_password\_ocid](#input\_db\_management\_password\_ocid) | OCID for Vault Secret to DB password | `string` | `null` | no |
| <a name="input_destinations"></a> [destinations](#input\_destinations) | Notifications topics for alarms to send to by OCID | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Variable for environment (dev/prd) | `string` | `"prd"` | no |
| <a name="input_exainfra_id"></a> [exainfra\_id](#input\_exainfra\_id) | AWS ExaData infra ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_exainfra_ocid"></a> [exainfra\_ocid](#input\_exainfra\_ocid) | OCI ExaData infra OCID | `string` | n/a | yes |
| <a name="input_in_downtime"></a> [in\_downtime](#input\_in\_downtime) | Flag to indicate if the system in downtime for maintenance | `bool` | `false` | no |
| <a name="input_notification_topic_ocid"></a> [notification\_topic\_ocid](#input\_notification\_topic\_ocid) | n/a | `string` | `null` | no |
| <a name="input_private_end_point_ocid"></a> [private\_end\_point\_ocid](#input\_private\_end\_point\_ocid) | OCID for DB Management Private End Point | `string` | `null` | no |
| <a name="input_recovery_window_in_days"></a> [recovery\_window\_in\_days](#input\_recovery\_window\_in\_days) | Retention period for backups. Must be between 7 and 95 days. | `number` | `null` | no |
| <a name="input_run_immediate_full_backup"></a> [run\_immediate\_full\_backup](#input\_run\_immediate\_full\_backup) | If true, OCI will manage automatic incremental backups. | `bool` | `null` | no |
| <a name="input_sns_alert_arn"></a> [sns\_alert\_arn](#input\_sns\_alert\_arn) | ARN string for sending data to SNS notifications (changes by region) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags for the cdb monitoring | `map(string)` | `null` | no |
| <a name="input_vm_cluster_id"></a> [vm\_cluster\_id](#input\_vm\_cluster\_id) | AWS VM Cluster ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_vm_cluster_name"></a> [vm\_cluster\_name](#input\_vm\_cluster\_name) | AWS VM Cluster Name | `string` | n/a | yes |
| <a name="input_vm_cluster_ocid"></a> [vm\_cluster\_ocid](#input\_vm\_cluster\_ocid) | OCI VM Cluster OCID | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cdb_management_resource"></a> [cdb\_management\_resource](#output\_cdb\_management\_resource) | n/a |
| <a name="output_cdb_resource"></a> [cdb\_resource](#output\_cdb\_resource) | CDB resource |
| <a name="output_cdb_resource_id"></a> [cdb\_resource\_id](#output\_cdb\_resource\_id) | Resource ID of CDB |
<!-- END_TF_DOCS -->

