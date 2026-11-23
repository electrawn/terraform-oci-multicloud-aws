
variable "project" {
  description = "Short project identifier (used in names/tags)."
  type        = string
}

variable "env" {
  description = "Environment (dev, prod, etc.)."
  type        = string
}

variable "region" {
  description = "AWS region to create backend resources in."
  type        = string
  default     = "us-east-1"
}

variable "s3_force_destroy" {
  description = "Allow bucket destroy even if objects exist (use carefully in non-prod)."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN for bucket encryption. If null, use SSE-S3."
  type        = string
  default     = null
}

variable "lifecycle_days" {
  description = "Days to transition non-current versions to Glacier and expire."
  type        = number
  default     = 365
}

variable "tags" {
  description = "Common tags for resources."
  type        = map(string)
  default     = {}
}

