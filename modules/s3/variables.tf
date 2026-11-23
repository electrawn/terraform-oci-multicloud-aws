# ---------------------------
# S3 Bucket module variables
# ---------------------------
variable "bucket_name" {
  description = "Name of the S3 bucket for dev environment"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the bucket"
  type        = map(string)
  default     = {}
}

variable "versioning_enabled" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = false
}
