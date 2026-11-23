

# ------------------------
# ODB Peering variables
# ------------------------
variable "peering_display_name" {
  description = "Display name for ODB peering connection"
  type        = string
  default     = null
}

variable "peering_odb_network_id" {
  description = "ID of the ODB network to peer"
  type        = string
  default     = null
}

variable "peering_network_id" {
  description = "ID of the peer network (e.g., AWS VPC)"
  type        = string
  default     = null
}

variable "peering_tags" {
  description = "Tags for the ODB peering resource"
  type        = map(string)
  default     = {}
}

