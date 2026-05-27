# cloudwatch-cdb-monitoring
This module provisions AWS CloudWatch alarms for CDB-level Oracle Database@AWS monitoring.

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
| [aws_cloudwatch_metric_alarm.cdb_Monitoring_user_password_expiration_critical](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cdb_Monitoring_user_password_expiration_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cdb_monitor_status](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cdb_processes_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cdb_storage_utilization_critical](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cdb_storage_utilization_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarms_enabled"></a> [alarms\_enabled](#input\_alarms\_enabled) | Master switch to enable or disable all CDB alarms | `bool` | `true` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Database Name | `string` | n/a | yes |
| <a name="input_database_ocid"></a> [database\_ocid](#input\_database\_ocid) | OCI Database OCID | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Variable for environment (dev/prd) | `string` | `"prd"` | no |
| <a name="input_exainfra_id"></a> [exainfra\_id](#input\_exainfra\_id) | AWS ExaData infra ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_exainfra_ocid"></a> [exainfra\_ocid](#input\_exainfra\_ocid) | OCI ExaData infra OCID | `string` | n/a | yes |
| <a name="input_in_downtime"></a> [in\_downtime](#input\_in\_downtime) | Flag to indicate if the system is in downtime for maintenance. When true, alarms will not send notifications | `bool` | `false` | no |
| <a name="input_is_enabled_cdb_monitor_status"></a> [is\_enabled\_cdb\_monitor\_status](#input\_is\_enabled\_cdb\_monitor\_status) | Enable or disable the cdb\_monitor\_status CloudWatch alarm | `bool` | `true` | no |
| <a name="input_is_enabled_cdb_processes_utilization"></a> [is\_enabled\_cdb\_processes\_utilization](#input\_is\_enabled\_cdb\_processes\_utilization) | Enable or disable the cdb\_processes\_utilization CloudWatch alarm | `bool` | `false` | no |
| <a name="input_is_enabled_cdb_storage_utilization_critical"></a> [is\_enabled\_cdb\_storage\_utilization\_critical](#input\_is\_enabled\_cdb\_storage\_utilization\_critical) | Enable or disable the cdb\_storage\_utilization\_critical CloudWatch alarm | `bool` | `false` | no |
| <a name="input_is_enabled_cdb_storage_utilization_warning"></a> [is\_enabled\_cdb\_storage\_utilization\_warning](#input\_is\_enabled\_cdb\_storage\_utilization\_warning) | Enable or disable the cdb\_storage\_utilization\_warning CloudWatch alarm | `bool` | `false` | no |
| <a name="input_is_enabled_cdb_user_password_expiration_critical"></a> [is\_enabled\_cdb\_user\_password\_expiration\_critical](#input\_is\_enabled\_cdb\_user\_password\_expiration\_critical) | Enable or disable the cdb\_Monitoring\_user\_password\_expiration\_critical CloudWatch alarm | `bool` | `false` | no |
| <a name="input_is_enabled_cdb_user_password_expiration_warning"></a> [is\_enabled\_cdb\_user\_password\_expiration\_warning](#input\_is\_enabled\_cdb\_user\_password\_expiration\_warning) | Enable or disable the cdb\_Monitoring\_user\_password\_expiration\_warning CloudWatch alarm | `bool` | `false` | no |
| <a name="input_sns_alert_arn"></a> [sns\_alert\_arn](#input\_sns\_alert\_arn) | ARN string for sending data to SNS notifications (changes by region) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Resource tags for the cdb Monitoring | `map(string)` | `null` | no |
| <a name="input_vm_cluster_id"></a> [vm\_cluster\_id](#input\_vm\_cluster\_id) | AWS VM Cluster ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_vm_cluster_name"></a> [vm\_cluster\_name](#input\_vm\_cluster\_name) | AWS VM Cluster Name | `string` | n/a | yes |
| <a name="input_vm_cluster_ocid"></a> [vm\_cluster\_ocid](#input\_vm\_cluster\_ocid) | OCI VM Cluster OCID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

