variable "route_table_id" {
  description = "AWS route table ID where the ODB route will be added"
  type        = string
}

variable "odb_network_cidr" {
  description = "ODB Network CIDR block"
  type        = string
}

variable "odb_network_interface_id" {
  description = "Network interface ID exposed by aws_odb_network"
  type        = string
}

