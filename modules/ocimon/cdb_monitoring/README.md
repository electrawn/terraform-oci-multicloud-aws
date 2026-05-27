# ocimon-cdb-monitoring
This module provisions OCI Monitoring alarms for CDB-level Oracle Database@AWS metrics.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [oci_monitoring_alarm.cdb_CPU_utilization](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm) | resource |
| [oci_monitoring_alarm.cdb_Flash_recovery_area_utilization](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm) | resource |
| [oci_monitoring_alarm.cdb_Monitoring_user_password_expiration](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm) | resource |
| [oci_monitoring_alarm.cdb_Processes_utilization](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm) | resource |
| [oci_monitoring_alarm.cdb_Storage_utilization](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm) | resource |
| [oci_monitoring_alarm.cdb_Tablespace_space_utilization](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarms_enabled"></a> [alarms\_enabled](#input\_alarms\_enabled) | Master switch to enable or disable all CDB alarms | `bool` | `true` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | OCID for compartment | `string` | n/a | yes |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Database Name | `string` | n/a | yes |
| <a name="input_database_ocid"></a> [database\_ocid](#input\_database\_ocid) | OCI Database OCID | `string` | n/a | yes |
| <a name="input_destinations"></a> [destinations](#input\_destinations) | Notifications topics for alarms to send to by OCID | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Variable for environment (dev/prd) | `string` | n/a | yes |
| <a name="input_exainfra_id"></a> [exainfra\_id](#input\_exainfra\_id) | AWS ExaData infra ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_exainfra_ocid"></a> [exainfra\_ocid](#input\_exainfra\_ocid) | OCI ExaData infra OCID | `string` | n/a | yes |
| <a name="input_in_downtime"></a> [in\_downtime](#input\_in\_downtime) | Flag to indicate if the system is in downtime for maintenance. When true, alarms will be disabled | `bool` | `false` | no |
| <a name="input_is_enabled_cdb_cpu_utilization"></a> [is\_enabled\_cdb\_cpu\_utilization](#input\_is\_enabled\_cdb\_cpu\_utilization) | Enable or disable the cdb CPU utilization OCI alarm | `bool` | `false` | no |
| <a name="input_is_enabled_cdb_flash_recovery_area_utilization"></a> [is\_enabled\_cdb\_flash\_recovery\_area\_utilization](#input\_is\_enabled\_cdb\_flash\_recovery\_area\_utilization) | Enable or disable the cdb Flash recovery area utilization OCI alarm | `bool` | `true` | no |
| <a name="input_is_enabled_cdb_processes_utilization"></a> [is\_enabled\_cdb\_processes\_utilization](#input\_is\_enabled\_cdb\_processes\_utilization) | Enable or disable the cdb Processes utilization OCI alarm | `bool` | `false` | no |
| <a name="input_is_enabled_cdb_storage_utilization"></a> [is\_enabled\_cdb\_storage\_utilization](#input\_is\_enabled\_cdb\_storage\_utilization) | Enable or disable the cdb Storage utilization alarm (warning + critical via overrides) | `bool` | `false` | no |
| <a name="input_is_enabled_cdb_tablespace_utilization"></a> [is\_enabled\_cdb\_tablespace\_utilization](#input\_is\_enabled\_cdb\_tablespace\_utilization) | Enable or disable the cdb Tablespace space utilization alarm (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_cdb_user_password_expiration"></a> [is\_enabled\_cdb\_user\_password\_expiration](#input\_is\_enabled\_cdb\_user\_password\_expiration) | Enable or disable the cdb Monitoring user password expiration alarm (warning + critical via overrides) | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional resource tags for the cdb Monitoring | `map(string)` | `null` | no |
| <a name="input_vm_cluster_id"></a> [vm\_cluster\_id](#input\_vm\_cluster\_id) | AWS VM Cluster ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_vm_cluster_name"></a> [vm\_cluster\_name](#input\_vm\_cluster\_name) | AWS VM Cluster Name | `string` | n/a | yes |
| <a name="input_vm_cluster_ocid"></a> [vm\_cluster\_ocid](#input\_vm\_cluster\_ocid) | OCI VM Cluster OCID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

