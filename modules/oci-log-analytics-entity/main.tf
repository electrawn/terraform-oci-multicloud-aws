resource "oci_log_analytics_log_analytics_entity" "this" {
  namespace        = var.namespace
  compartment_id   = var.compartment_id
  name             = var.name
  entity_type_name = var.entity_type_name

  hostname            = var.hostname
  cloud_resource_id   = var.cloud_resource_id
  management_agent_id = var.management_agent_id
  timezone_region     = var.timezone_region
  properties          = length(var.properties) > 0 ? var.properties : null
  freeform_tags       = length(var.freeform_tags) > 0 ? var.freeform_tags : null
  defined_tags        = length(var.defined_tags) > 0 ? var.defined_tags : null

  dynamic "metadata" {
    for_each = length(var.metadata_items) > 0 ? [1] : []
    content {
      dynamic "items" {
        for_each = var.metadata_items
        content {
          name  = items.value.name
          type  = items.value.type
          value = items.value.value
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      time_last_discovered
    ]
  }
}

# ---------------------------------------------------------------------------
# Source associations — associate log sources with this entity.
# Each association links the entity to a log source in a specified log group.
# A time_sleep ensures the entity is fully ACTIVE before attempting association.
# ---------------------------------------------------------------------------
resource "time_sleep" "wait_for_entity" {
  count           = length(var.source_associations) > 0 ? 1 : 0
  depends_on      = [oci_log_analytics_log_analytics_entity.this]
  create_duration = "30s"
}

resource "oci_log_analytics_namespace_association" "this" {
  for_each = { for assoc in var.source_associations : assoc.source_name => assoc }

  namespace      = var.namespace
  compartment_id = each.value.compartment_id
  entity_id      = oci_log_analytics_log_analytics_entity.this.id
  source_name    = each.value.source_name
  log_group_id   = each.value.log_group_id

  depends_on = [time_sleep.wait_for_entity]
}
