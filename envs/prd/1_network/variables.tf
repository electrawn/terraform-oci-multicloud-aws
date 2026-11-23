
# ------------------------
# ODB Network variables
# ------------------------
variable "aws_odb_network_availability_zone_id" {
  description = "Availability Zone ID of the ODB network"
  type        = string
  default     = "use1-az4"
}

variable "aws_odb_network_display_name" {
  description = "Name of the ODB network"
  type        = string
  default     = "useast1-az4-prd-odbn-01"
}

variable "aws_odb_network_client_subnet_cidr" {
  description = "Client subnet CIDR range of the ODB network"
  type        = string
  default     = "10.0.129.0/25"
}

variable "aws_odb_network_backup_subnet_cidr" {
  description = "Backup subnet CIDR range of the ODB network"
  type        = string
  default     = "10.0.129.128/25"
}

variable "aws_odb_network_custom_domain_name" {
  description = "AWS ODB network custom domain name. You can provide this value or aws_odb_network_default_dns_prefix value"
  type        = string
  default     = null
}

variable "aws_odb_network_default_dns_prefix" {
  description = "AWS ODB network default DNS prefix. You can provide this value or aws_odb_network_custom_domain_name value"
  type        = string
  default     = "example"
}

variable "aws_odb_network_s3_access" {
  description = "The configuration for Amazon S3 access from the ODB network"
  type        = string
  default     = "DISABLED"
}

variable "aws_odb_network_zero_etl_access" {
  description = "The configuration for Zero-ETL access from the ODB network"
  type        = string
  default     = "DISABLED"
}

variable "aws_odb_network_s3_policy_document" {
  description = "The s3 policy document for Amazon S3 access from the ODB network"
  type        = string
  default     = null
}


# ------------------------
# ODB Peering variables
# ------------------------
variable "peering_display_name" {
  description = "Display name for ODB peering connection"
  type        = string
  default     = "odb_to_exadata-p_prd_vpc_peering"
}

variable "peering_odb_network_id" {
  description = "ID of the ODB network to peer"
  type        = string
  default     = "odbnet_example0002"
}

variable "peering_network_id" {
  description = "ID of the peer network (e.g., AWS VPC)"
  type        = string
  default     = "vpc-0fdb8e1929840ca56"
}

variable "tags" {
  description = "Tags for the ODB peering resource"
  type        = map(string)
  default = {
    created_by  = "terraform"
    Team        = "Database Team"
    Environment = "prd"
  }
}

