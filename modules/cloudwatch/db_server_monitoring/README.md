# cloudwatch-db-server-monitoring
This module provisions AWS CloudWatch alarms for DB server node metrics and filesystem utilization.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.15.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.15.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_metric_alarm.acfs01_filesystem_utilization_crit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.acfs01_filesystem_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.boot_filesystem_utilization_crit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.boot_filesystem_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.crashfiles_filesystem_utilization_crit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.crashfiles_filesystem_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.home_filesystem_utilization_crit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.home_filesystem_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.node_status](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.root_filesystem_utilization_crit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.root_filesystem_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.tmp_filesystem_utilization_crit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.tmp_filesystem_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.u01_app_grid_filesystem_utilization_crit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.u01_app_grid_filesystem_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.u01_filesystem_utilization_crit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.u01_filesystem_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.u02_filesystem_utilization_crit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.u02_filesystem_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.var_filesystem_utilization_crit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.var_filesystem_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.var_log_audit_filesystem_utilization_crit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.var_log_audit_filesystem_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.var_log_filesystem_utilization_crit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.var_log_filesystem_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.vm_cluster_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.vm_cluster_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aws_exainfra_dbservers"></a> [aws\_exainfra\_dbservers](#input\_aws\_exainfra\_dbservers) | DataSource from aws\_odb\_db\_servers | `any` | n/a | yes |
| <a name="input_aws_vmcluster_dbnodes"></a> [aws\_vmcluster\_dbnodes](#input\_aws\_vmcluster\_dbnodes) | DataSource from aws\_odb\_db\_nodes | `any` | n/a | yes |
| <a name="input_db_server_id"></a> [db\_server\_id](#input\_db\_server\_id) | AWS DB Server ID for Oracle DB (AWS ID) | `string` | `null` | no |
| <a name="input_db_servers"></a> [db\_servers](#input\_db\_servers) | list of DB Servers node ids from VMCluster resource | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Variable for environment (dev/prd) | `string` | `"prd"` | no |
| <a name="input_exainfra_id"></a> [exainfra\_id](#input\_exainfra\_id) | AWS ExaData infra ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_exainfra_name"></a> [exainfra\_name](#input\_exainfra\_name) | AWS ExaData infra Name | `string` | n/a | yes |
| <a name="input_exainfra_ocid"></a> [exainfra\_ocid](#input\_exainfra\_ocid) | OCI ExaData infra OCID | `string` | n/a | yes |
| <a name="input_in_downtime"></a> [in\_downtime](#input\_in\_downtime) | Flag to indicate if the system is in downtime for maintenance. When true, alarms will not send notifications | `bool` | `false` | no |
| <a name="input_is_enabled_acfs01_filesystem_utilization_crit"></a> [is\_enabled\_acfs01\_filesystem\_utilization\_crit](#input\_is\_enabled\_acfs01\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarm for /acfs01 mount point | `bool` | `true` | no |
| <a name="input_is_enabled_acfs01_filesystem_utilization_warning"></a> [is\_enabled\_acfs01\_filesystem\_utilization\_warning](#input\_is\_enabled\_acfs01\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarm for /acfs01 mount point | `bool` | `true` | no |
| <a name="input_is_enabled_boot_filesystem_utilization_crit"></a> [is\_enabled\_boot\_filesystem\_utilization\_crit](#input\_is\_enabled\_boot\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarm for /boot mount point | `bool` | `true` | no |
| <a name="input_is_enabled_boot_filesystem_utilization_warning"></a> [is\_enabled\_boot\_filesystem\_utilization\_warning](#input\_is\_enabled\_boot\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarm for /boot mount point | `bool` | `true` | no |
| <a name="input_is_enabled_crashfiles_filesystem_utilization_crit"></a> [is\_enabled\_crashfiles\_filesystem\_utilization\_crit](#input\_is\_enabled\_crashfiles\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarm for /crashfiles mount point | `bool` | `true` | no |
| <a name="input_is_enabled_crashfiles_filesystem_utilization_warning"></a> [is\_enabled\_crashfiles\_filesystem\_utilization\_warning](#input\_is\_enabled\_crashfiles\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarm for /crashfiles mount point | `bool` | `true` | no |
| <a name="input_is_enabled_filesystem_utilization_crit"></a> [is\_enabled\_filesystem\_utilization\_crit](#input\_is\_enabled\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarms | `bool` | `true` | no |
| <a name="input_is_enabled_filesystem_utilization_warning"></a> [is\_enabled\_filesystem\_utilization\_warning](#input\_is\_enabled\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarms | `bool` | `true` | no |
| <a name="input_is_enabled_home_filesystem_utilization_crit"></a> [is\_enabled\_home\_filesystem\_utilization\_crit](#input\_is\_enabled\_home\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarm for /home mount point | `bool` | `true` | no |
| <a name="input_is_enabled_home_filesystem_utilization_warning"></a> [is\_enabled\_home\_filesystem\_utilization\_warning](#input\_is\_enabled\_home\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarm for /home mount point | `bool` | `true` | no |
| <a name="input_is_enabled_node_status"></a> [is\_enabled\_node\_status](#input\_is\_enabled\_node\_status) | Enable or disable the node\_status CloudWatch alarm | `bool` | `true` | no |
| <a name="input_is_enabled_root_filesystem_utilization_crit"></a> [is\_enabled\_root\_filesystem\_utilization\_crit](#input\_is\_enabled\_root\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarm for / mount point | `bool` | `true` | no |
| <a name="input_is_enabled_root_filesystem_utilization_warning"></a> [is\_enabled\_root\_filesystem\_utilization\_warning](#input\_is\_enabled\_root\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarm for / mount point | `bool` | `true` | no |
| <a name="input_is_enabled_tmp_filesystem_utilization_crit"></a> [is\_enabled\_tmp\_filesystem\_utilization\_crit](#input\_is\_enabled\_tmp\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarm for /tmp mount point | `bool` | `true` | no |
| <a name="input_is_enabled_tmp_filesystem_utilization_warning"></a> [is\_enabled\_tmp\_filesystem\_utilization\_warning](#input\_is\_enabled\_tmp\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarm for /tmp mount point | `bool` | `true` | no |
| <a name="input_is_enabled_u01_app_grid_filesystem_utilization_crit"></a> [is\_enabled\_u01\_app\_grid\_filesystem\_utilization\_crit](#input\_is\_enabled\_u01\_app\_grid\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarm for /u01/app/23.0.0.0/grid mount point | `bool` | `true` | no |
| <a name="input_is_enabled_u01_app_grid_filesystem_utilization_warning"></a> [is\_enabled\_u01\_app\_grid\_filesystem\_utilization\_warning](#input\_is\_enabled\_u01\_app\_grid\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarm for /u01/app/23.0.0.0/grid mount point | `bool` | `true` | no |
| <a name="input_is_enabled_u01_filesystem_utilization_crit"></a> [is\_enabled\_u01\_filesystem\_utilization\_crit](#input\_is\_enabled\_u01\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarm for u01 mount point | `bool` | `true` | no |
| <a name="input_is_enabled_u01_filesystem_utilization_warning"></a> [is\_enabled\_u01\_filesystem\_utilization\_warning](#input\_is\_enabled\_u01\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarm for /u01 mount point | `bool` | `true` | no |
| <a name="input_is_enabled_u02_filesystem_utilization_crit"></a> [is\_enabled\_u02\_filesystem\_utilization\_crit](#input\_is\_enabled\_u02\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarm for /u02 mount point | `bool` | `true` | no |
| <a name="input_is_enabled_u02_filesystem_utilization_warning"></a> [is\_enabled\_u02\_filesystem\_utilization\_warning](#input\_is\_enabled\_u02\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarm for /u02 mount point | `bool` | `true` | no |
| <a name="input_is_enabled_var_filesystem_utilization_crit"></a> [is\_enabled\_var\_filesystem\_utilization\_crit](#input\_is\_enabled\_var\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarm for /var mount point | `bool` | `true` | no |
| <a name="input_is_enabled_var_filesystem_utilization_warning"></a> [is\_enabled\_var\_filesystem\_utilization\_warning](#input\_is\_enabled\_var\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarm for /var mount point | `bool` | `true` | no |
| <a name="input_is_enabled_var_log_audit_filesystem_utilization_crit"></a> [is\_enabled\_var\_log\_audit\_filesystem\_utilization\_crit](#input\_is\_enabled\_var\_log\_audit\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarm for /var/log/audit mount point | `bool` | `true` | no |
| <a name="input_is_enabled_var_log_audit_filesystem_utilization_warning"></a> [is\_enabled\_var\_log\_audit\_filesystem\_utilization\_warning](#input\_is\_enabled\_var\_log\_audit\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarm for /var/log/audit mount point | `bool` | `true` | no |
| <a name="input_is_enabled_var_log_filesystem_utilization_crit"></a> [is\_enabled\_var\_log\_filesystem\_utilization\_crit](#input\_is\_enabled\_var\_log\_filesystem\_utilization\_crit) | Enable or disable all filesystem critical CloudWatch alarm for /var/log mount point | `bool` | `true` | no |
| <a name="input_is_enabled_var_log_filesystem_utilization_warning"></a> [is\_enabled\_var\_log\_filesystem\_utilization\_warning](#input\_is\_enabled\_var\_log\_filesystem\_utilization\_warning) | Enable or disable all filesystem warning CloudWatch alarm for /var/log mount point | `bool` | `true` | no |
| <a name="input_is_enabled_vm_cluster_cpu"></a> [is\_enabled\_vm\_cluster\_cpu](#input\_is\_enabled\_vm\_cluster\_cpu) | Enable or disable the vm\_cluster\_cpu CloudWatch alarm | `bool` | `false` | no |
| <a name="input_is_enabled_vm_cluster_memory"></a> [is\_enabled\_vm\_cluster\_memory](#input\_is\_enabled\_vm\_cluster\_memory) | Enable or disable the vm\_cluster\_memory CloudWatch alarm | `bool` | `false` | no |
| <a name="input_sns_alert_arn"></a> [sns\_alert\_arn](#input\_sns\_alert\_arn) | ARN string for sending data to SNS notifications (changes by region) | `string` | `null` | no |
| <a name="input_vm_cluster_id"></a> [vm\_cluster\_id](#input\_vm\_cluster\_id) | AWS VM Cluster ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_vm_cluster_name"></a> [vm\_cluster\_name](#input\_vm\_cluster\_name) | AWS VM Cluster Name | `string` | n/a | yes |
| <a name="input_vm_cluster_ocid"></a> [vm\_cluster\_ocid](#input\_vm\_cluster\_ocid) | OCI VM Cluster OCID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

