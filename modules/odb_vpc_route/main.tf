resource "aws_route" "to_odb_network" {
  route_table_id         = var.route_table_id
  destination_cidr_block = var.odb_network_cidr
  network_interface_id   = var.odb_network_interface_id
}
