variable "peering_display_name" {
  description = "Display name for the peering connection"
  type        = string
}

variable "peering_odb_network_id" {
  description = "The ID of the ODB network that will be peered"
  type        = string
}

variable "peering_network_id" {
  description = "The ID of the peer VPC network"
  type        = string
}

variable "peering_tags" {
  description = "Tags for the ODB network peering connection"
  type        = map(string)
  default     = {}
}
