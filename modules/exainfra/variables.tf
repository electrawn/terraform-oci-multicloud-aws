
# ------------------------
# Exadata module variables (kept as you shared)
# ------------------------
variable "exa_x11m_display_name" { type = string }
variable "exa_x11m_shape" { type = string }
variable "exa_x11m_storage_count" { type = number }
variable "exa_x11m_compute_count" { type = number }
variable "exa_x11m_availability_zone_id" { type = string }

variable "exa_x11m_contacts" {
  type    = list(object({ email = string }))
  default = []
}

variable "exa_x11m_database_type" { type = string } # maps to database_server_type
variable "exa_x11m_storage_type" { type = string }  # maps to storage_server_type

variable "exa_x11m_tags" { type = map(string) }

variable "exa_x11m_maint" {
  type = object({
    custom_action_timeout_in_mins    = number
    days_of_week                     = list(object({ name = string }))
    hours_of_day                     = list(number)
    is_custom_action_timeout_enabled = bool
    lead_time_in_weeks               = number
    months                           = list(object({ name = string }))
    patching_mode                    = string
    preference                       = string # "CUSTOM_PREFERENCE" or "NO_PREFERENCE"
    weeks_of_month                   = list(number)
  })
}

