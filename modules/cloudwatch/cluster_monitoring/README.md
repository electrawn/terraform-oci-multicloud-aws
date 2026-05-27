# cloudwatch-cluster-monitoring
This module provisions AWS CloudWatch alarms for VM cluster and ASM storage monitoring.

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
| [aws_cloudwatch_metric_alarm.asm_storage_data1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.asm_storage_reco1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_odb_cloud_exadata_infrastructure.exainfra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/odb_cloud_exadata_infrastructure) | data source |
| [aws_odb_cloud_vm_cluster.vm_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/odb_cloud_vm_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Variable for environment (dev/prd) | `string` | `"prd"` | no |
| <a name="input_exainfra_id"></a> [exainfra\_id](#input\_exainfra\_id) | AWS ExaData infra ID for Oracle DB (AWS ID) | `string` | n/a | yes |
| <a name="input_in_downtime"></a> [in\_downtime](#input\_in\_downtime) | Flag to indicate if the system is in downtime for maintenance. When true, alarms will not send notifications | `bool` | `false` | no |
| <a name="input_is_enabled_asm_storage_data1"></a> [is\_enabled\_asm\_storage\_data1](#input\_is\_enabled\_asm\_storage\_data1) | Enable or disable the asm\_storage\_data1 CloudWatch alarm | `bool` | `true` | no |
| <a name="input_is_enabled_asm_storage_reco1"></a> [is\_enabled\_asm\_storage\_reco1](#input\_is\_enabled\_asm\_storage\_reco1) | Enable or disable the asm\_storage\_reco1 CloudWatch alarm | `bool` | `true` | no |
| <a name="input_sns_alert_arn"></a> [sns\_alert\_arn](#input\_sns\_alert\_arn) | ARN string for sending data to SNS notifications (changes by region) | `string` | `null` | no |
| <a name="input_vm_cluster_id"></a> [vm\_cluster\_id](#input\_vm\_cluster\_id) | AWS VM Cluster ID for Oracle DB (AWS ID) | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

