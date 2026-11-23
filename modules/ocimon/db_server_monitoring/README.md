# ocimon-db-server-monitoring
This module provisions OCI Monitoring alarms for DB server node health and filesystem metrics.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [oci_monitoring_alarm.db_server_alarms](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm) | resource |
| [oci_monitoring_alarm.db_server_filesystem_alarms](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm) | resource |
| [aws_odb_db_nodes.db_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/odb_db_nodes) | data source |
| [aws_odb_db_servers.db_servers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/odb_db_servers) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarms_enabled"></a> [alarms\_enabled](#input\_alarms\_enabled) | Master switch to enable or disable all DB server alarms | `bool` | `true` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | OCID for compartment | `string` | n/a | yes |
| <a name="input_db_server_id"></a> [db\_server\_id](#input\_db\_server\_id) | AWS DB Server ID for Oracle DB (AWS ID) | `string` | `null` | no |
| <a name="input_destinations"></a> [destinations](#input\_destinations) | Notifications topics for alarms to send to by OCID | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Variable for environment (dev/prd) | `string` | n/a | yes |
| <a name="input_exainfra_id"></a> [exainfra\_id](#input\_exainfra\_id) | AWS ExaData infra ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_exainfra_name"></a> [exainfra\_name](#input\_exainfra\_name) | AWS ExaData infra Name | `string` | n/a | yes |
| <a name="input_exainfra_ocid"></a> [exainfra\_ocid](#input\_exainfra\_ocid) | OCI ExaData infra OCID | `string` | n/a | yes |
| <a name="input_in_downtime"></a> [in\_downtime](#input\_in\_downtime) | Flag to indicate if the system is in downtime for maintenance. When true, alarms will be disabled | `bool` | `false` | no |
| <a name="input_is_enabled_acfs01_filesystem_utilization"></a> [is\_enabled\_acfs01\_filesystem\_utilization](#input\_is\_enabled\_acfs01\_filesystem\_utilization) | Enable or disable filesystem alarm for /acfs01 (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_boot_filesystem_utilization"></a> [is\_enabled\_boot\_filesystem\_utilization](#input\_is\_enabled\_boot\_filesystem\_utilization) | Enable or disable filesystem alarm for /boot (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_crashfiles_filesystem_utilization"></a> [is\_enabled\_crashfiles\_filesystem\_utilization](#input\_is\_enabled\_crashfiles\_filesystem\_utilization) | Enable or disable filesystem alarm for /crashfiles (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_filesystem_utilization"></a> [is\_enabled\_filesystem\_utilization](#input\_is\_enabled\_filesystem\_utilization) | Master switch to enable or disable all filesystem alarms (each alarm has warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_home_filesystem_utilization"></a> [is\_enabled\_home\_filesystem\_utilization](#input\_is\_enabled\_home\_filesystem\_utilization) | Enable or disable filesystem alarm for /home (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_node_status"></a> [is\_enabled\_node\_status](#input\_is\_enabled\_node\_status) | Enable or disable the node\_status alarm | `bool` | `true` | no |
| <a name="input_is_enabled_root_filesystem_utilization"></a> [is\_enabled\_root\_filesystem\_utilization](#input\_is\_enabled\_root\_filesystem\_utilization) | Enable or disable filesystem alarm for / (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_tmp_filesystem_utilization"></a> [is\_enabled\_tmp\_filesystem\_utilization](#input\_is\_enabled\_tmp\_filesystem\_utilization) | Enable or disable filesystem alarm for /tmp (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_u01_app_grid_filesystem_utilization"></a> [is\_enabled\_u01\_app\_grid\_filesystem\_utilization](#input\_is\_enabled\_u01\_app\_grid\_filesystem\_utilization) | Enable or disable filesystem alarm for /u01/app/23.0.0.0/grid (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_u01_filesystem_utilization"></a> [is\_enabled\_u01\_filesystem\_utilization](#input\_is\_enabled\_u01\_filesystem\_utilization) | Enable or disable filesystem alarm for /u01 (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_u02_filesystem_utilization"></a> [is\_enabled\_u02\_filesystem\_utilization](#input\_is\_enabled\_u02\_filesystem\_utilization) | Enable or disable filesystem alarm for /u02 (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_var_filesystem_utilization"></a> [is\_enabled\_var\_filesystem\_utilization](#input\_is\_enabled\_var\_filesystem\_utilization) | Enable or disable filesystem alarm for /var (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_var_log_audit_filesystem_utilization"></a> [is\_enabled\_var\_log\_audit\_filesystem\_utilization](#input\_is\_enabled\_var\_log\_audit\_filesystem\_utilization) | Enable or disable filesystem alarm for /var/log/audit (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_var_log_filesystem_utilization"></a> [is\_enabled\_var\_log\_filesystem\_utilization](#input\_is\_enabled\_var\_log\_filesystem\_utilization) | Enable or disable filesystem alarm for /var/log (warning + critical via overrides) | `bool` | `true` | no |
| <a name="input_is_enabled_vm_cluster_cpu"></a> [is\_enabled\_vm\_cluster\_cpu](#input\_is\_enabled\_vm\_cluster\_cpu) | Enable or disable the vm\_cluster\_cpu alarm | `bool` | `false` | no |
| <a name="input_is_enabled_vm_cluster_memory"></a> [is\_enabled\_vm\_cluster\_memory](#input\_is\_enabled\_vm\_cluster\_memory) | Enable or disable the vm\_cluster\_memory alarm | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional resource tags for DB server monitoring | `map(string)` | `null` | no |
| <a name="input_vm_cluster_id"></a> [vm\_cluster\_id](#input\_vm\_cluster\_id) | AWS VM Cluster ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_vm_cluster_name"></a> [vm\_cluster\_name](#input\_vm\_cluster\_name) | AWS VM Cluster Name | `string` | n/a | yes |
| <a name="input_vm_cluster_ocid"></a> [vm\_cluster\_ocid](#input\_vm\_cluster\_ocid) | OCI VM Cluster OCID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

