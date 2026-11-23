resource "aws_odb_network_peering_connection" "this" {
  display_name    = var.peering_display_name
  odb_network_id  = var.peering_odb_network_id
  peer_network_id = var.peering_network_id
  tags            = var.peering_tags
}
