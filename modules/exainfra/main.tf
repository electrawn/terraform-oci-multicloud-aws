
# Exadata Infrastructure in AWS ODB
# Resource: aws_odb_cloud_exadata_infrastructure
# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/odb_cloud_exadata_infrastructure
#      https://docs.public.content.oci.oraclecloud.com/.../awscs-code-samples-terraform.html

resource "aws_odb_cloud_exadata_infrastructure" "this" {
  display_name         = var.exa_x11m_display_name
  shape                = var.exa_x11m_shape
  storage_count        = var.exa_x11m_storage_count
  compute_count        = var.exa_x11m_compute_count
  availability_zone_id = var.exa_x11m_availability_zone_id

  # Optional mappings
  customer_contacts_to_send_to_oci = var.exa_x11m_contacts
  database_server_type             = var.exa_x11m_database_type
  storage_server_type              = var.exa_x11m_storage_type
  tags                             = var.exa_x11m_tags

  # Maintenance Window (Oracle-managed or Custom)
  maintenance_window {
    patching_mode                    = var.exa_x11m_maint.patching_mode
    preference                       = var.exa_x11m_maint.preference
    is_custom_action_timeout_enabled = var.exa_x11m_maint.is_custom_action_timeout_enabled
    custom_action_timeout_in_mins    = var.exa_x11m_maint.custom_action_timeout_in_mins

    # Only emit schedules when using CUSTOM_PREFERENCE
    dynamic "days_of_week" {
      for_each = var.exa_x11m_maint.preference == "CUSTOM_PREFERENCE" ? var.exa_x11m_maint.days_of_week : []
      content {
        name = days_of_week.value.name
      }
    }

    hours_of_day       = var.exa_x11m_maint.preference == "CUSTOM_PREFERENCE" ? var.exa_x11m_maint.hours_of_day : null
    lead_time_in_weeks = var.exa_x11m_maint.preference == "CUSTOM_PREFERENCE" ? var.exa_x11m_maint.lead_time_in_weeks : null

    dynamic "months" {
      for_each = var.exa_x11m_maint.preference == "CUSTOM_PREFERENCE" ? var.exa_x11m_maint.months : []
      content {
        name = months.value.name
      }
    }

    weeks_of_month = var.exa_x11m_maint.preference == "CUSTOM_PREFERENCE" ? var.exa_x11m_maint.weeks_of_month : null
  }
}

# Discover DB Server IDs under this Exadata (used by VM clusters)
# Data source: aws_odb_db_servers
data "aws_odb_db_servers" "this" {
  cloud_exadata_infrastructure_id = aws_odb_cloud_exadata_infrastructure.this.id
  depends_on                      = [aws_odb_cloud_exadata_infrastructure.this]
}

