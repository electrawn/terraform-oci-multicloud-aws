variable "region" {
  type        = string
  description = "OCI region, e.g. us-ashburn-1."
}

variable "env" {
  type        = string
  description = "Short environment name used in resource names (e.g. tst, prd)."
}

variable "tenancy_ocid" {
  type        = string
  description = "Tenancy OCID. Only used when create_iam is true (dynamic groups and policies live in the tenancy)."
  default     = ""
}

variable "compartment_ocid" {
  type        = string
  description = "Compartment that holds the Functions application, the functions and the published metrics (the monitor compartment)."
}

variable "db_compartment_ocid" {
  type        = string
  description = "Compartment that holds the Exadata VM clusters the check discovers."
}

variable "subnet_ocids" {
  type        = list(string)
  description = "Subnet(s) for the Functions application. Must be able to reach the DB nodes on the SSH port."
}

variable "function_image" {
  type        = string
  description = "Fully-qualified OCIR image, e.g. <region>.ocir.io/<namespace>/ssh-check:0.0.1"
}

variable "clusters" {
  type = map(object({
    cluster_name = string
  }))
  description = "One ssh-check function per VM cluster. Key becomes the function name suffix; cluster_name is the VM cluster display name."
}

variable "ssh_check_domain" {
  type        = string
  description = "Admin DNS domain appended to the node hostname when ssh_check_target = admin."
  default     = "admin.example.internal"
}

variable "ssh_check_target" {
  type        = string
  description = "Node address to probe: admin, primary or vip."
  default     = "admin"

  validation {
    condition     = contains(["admin", "primary", "vip"], var.ssh_check_target)
    error_message = "ssh_check_target must be admin, primary or vip"
  }
}

variable "create_iam" {
  type        = bool
  description = "Create the resource-principal dynamic group and policy. Set false if IAM is managed elsewhere."
  default     = false
}

variable "scheduler_enabled" {
  type        = bool
  description = "Create an OCI Resource Scheduler schedule that invokes the functions hourly."
  default     = true
}

variable "scheduler_minute" {
  type        = number
  description = "Minute of the hour at which the hourly schedule fires (Resource Scheduler's minimum frequency is hourly)."
  default     = 0

  validation {
    condition     = var.scheduler_minute >= 0 && var.scheduler_minute < 60
    error_message = "scheduler_minute must be between 0 and 59"
  }
}

variable "tags" {
  type        = map(string)
  description = "Free-form tags applied to all resources."
  default     = {}
}
