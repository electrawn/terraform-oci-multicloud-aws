# ---------------------------
# ODB Network Peering Module
# ---------------------------
module "odb_peering" {
  source = "../../../../modules/aws-odb-peering"

  display_name    = var.peering_display_name
  odb_network_id  = var.peering_odb_network_id # specify which ODB network to peer
  peer_network_id = var.peering_network_id
  tags            = var.peering_tags
}
