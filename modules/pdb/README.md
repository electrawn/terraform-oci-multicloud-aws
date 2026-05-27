# pdb
This module provisions a Pluggable Database (PDB) and wires CloudWatch and OCI monitoring modules.

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
| <a name="module_cloudwatch_monitor"></a> [cloudwatch\_monitor](#module\_cloudwatch\_monitor) | ../cloudwatch/pdb_monitoring | n/a |
| <a name="module_ocimon_monitor"></a> [ocimon\_monitor](#module\_ocimon\_monitor) | ../ocimon/pdb_monitoring | n/a |
| <a name="module_pdb"></a> [pdb](#module\_pdb) | ../oci-db-pdb | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [oci_database_pluggable_database_pluggabledatabasemanagements_management.pdb_management](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_pluggable_database_pluggabledatabasemanagements_management) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarms_enabled"></a> [alarms\_enabled](#input\_alarms\_enabled) | Master switch to enable or disable CloudWatch alarms | `bool` | `true` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | OCID for compartment | `string` | n/a | yes |
| <a name="input_container_database_ocid"></a> [container\_database\_ocid](#input\_container\_database\_ocid) | OCI Database CDB OCID | `string` | n/a | yes |
| <a name="input_db_management_password_ocid"></a> [db\_management\_password\_ocid](#input\_db\_management\_password\_ocid) | OCID for Vault Secret to DB password | `string` | `null` | no |
| <a name="input_destinations"></a> [destinations](#input\_destinations) | Notifications topics for alarms to send to by OCID | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Variable for environment (dev/prd) | `string` | `"prd"` | no |
| <a name="input_exainfra_id"></a> [exainfra\_id](#input\_exainfra\_id) | AWS ExaData infra ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_exainfra_ocid"></a> [exainfra\_ocid](#input\_exainfra\_ocid) | OCI ExaData infra OCID | `string` | n/a | yes |
| <a name="input_in_downtime"></a> [in\_downtime](#input\_in\_downtime) | Flag to indicate if the system in downtime for maintenance | `bool` | `false` | no |
| <a name="input_notification_topic_ocid"></a> [notification\_topic\_ocid](#input\_notification\_topic\_ocid) | n/a | `string` | `null` | no |
| <a name="input_pdb_admin_password"></a> [pdb\_admin\_password](#input\_pdb\_admin\_password) | A strong password for SYS, SYSTEM, PDB Admin and TDE Wallet. | `string` | `null` | no |
| <a name="input_pdb_auto_backup_enabled"></a> [pdb\_auto\_backup\_enabled](#input\_pdb\_auto\_backup\_enabled) | Enable automatic backup (optional), default false | `bool` | `false` | no |
| <a name="input_pdb_name"></a> [pdb\_name](#input\_pdb\_name) | The display name of the database. (required) | `string` | n/a | yes |
| <a name="input_pdb_source"></a> [pdb\_source](#input\_pdb\_source) | The source of the database (optional), default NONE. | `string` | `"NONE"` | no |
| <a name="input_pdb_tde_wallet_password"></a> [pdb\_tde\_wallet\_password](#input\_pdb\_tde\_wallet\_password) | A strong password for SYS, SYSTEM, PDB Admin and TDE Wallet. | `string` | `null` | no |
| <a name="input_private_end_point_ocid"></a> [private\_end\_point\_ocid](#input\_private\_end\_point\_ocid) | OCID for DB Management Private End Point | `string` | `null` | no |
| <a name="input_sns_alert_arn"></a> [sns\_alert\_arn](#input\_sns\_alert\_arn) | ARN string for sending data to SNS notifications (changes by region) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags for the cdb monitoring | `map(string)` | `null` | no |
| <a name="input_vm_cluster_id"></a> [vm\_cluster\_id](#input\_vm\_cluster\_id) | AWS VM Cluster ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_vm_cluster_name"></a> [vm\_cluster\_name](#input\_vm\_cluster\_name) | AWS VM Cluster Name | `string` | n/a | yes |
| <a name="input_vm_cluster_ocid"></a> [vm\_cluster\_ocid](#input\_vm\_cluster\_ocid) | OCI VM Cluster OCID | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_pdb_management_resource"></a> [pdb\_management\_resource](#output\_pdb\_management\_resource) | n/a |
| <a name="output_pdb_resource"></a> [pdb\_resource](#output\_pdb\_resource) | CDB resource |
| <a name="output_pdb_resource_id"></a> [pdb\_resource\_id](#output\_pdb\_resource\_id) | Resource ID of CDB |
<!-- END_TF_DOCS -->

