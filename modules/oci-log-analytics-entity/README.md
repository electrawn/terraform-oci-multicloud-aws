# oci-log-analytics-entity

Thin single-resource wrapper for `oci_log_analytics_log_analytics_entity`.

Creates a Log Analytics entity representing a database instance on a specific
DB node. One entity is needed per CDB per DB node to enable log ingestion.

## Usage

```hcl
module "cdb069_node1_log_entity" {
  source = "../../../modules/oracle-modules/oci-log-analytics-entity"

  namespace         = "mytenancy"
  compartment_id    = var.compartment_ocid
  name              = "cdb069-node1"
  entity_type_name  = "Oracle Database"
  hostname          = "dbnode1.example.com"
  cloud_resource_id = "ocid1.database.oc1.iad.xxx"
}
```

## Import

```bash
terraform import 'module.cdb069_node1_log_entity.oci_log_analytics_log_analytics_entity.this' \
  'namespaces/{namespaceName}/logAnalyticsEntities/{logAnalyticsEntityId}'
```
