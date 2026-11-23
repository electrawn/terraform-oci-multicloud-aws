# Variables for ssh-check module

variable "env" {
  type        = string
  description = "Environment name: prd, stg, dev, sbx"

  validation {
    condition     = contains(["prd", "stg", "dev", "sbx"], var.env)
    error_message = "env must be one of: prd, stg, dev, sbx"
  }
}

variable "region" {
  type        = string
  description = "OCI region (e.g., us-ashburn-1)"
}

variable "compartment_ocid" {
  type        = string
  description = "OCI Compartment OCID for the environment"

  validation {
    condition     = trimspace(var.compartment_ocid) != ""
    error_message = "compartment_ocid must be a non-empty OCI compartment OCID"
  }
}

variable "application_ocid" {
  type        = string
  description = "OCID of the shared OCI Functions Application"

  validation {
    condition     = trimspace(var.application_ocid) != ""
    error_message = "application_ocid must be the OCID of the OCI Functions Application"
  }
}

variable "function_image" {
  type        = string
  description = "Fully-qualified OCIR image reference for the function (e.g., region.ocir.io/namespace/repo:tag or region.ocir.io/namespace/repo@sha256:digest)"

  validation {
    condition     = var.function_image != ""
    error_message = "function_image must be a non-empty OCIR image reference"
  }
}

variable "function_memory_in_mbs" {
  type        = number
  description = "Memory allocation for the function in MB"
  default     = 256

  validation {
    condition     = var.function_memory_in_mbs >= 128 && var.function_memory_in_mbs <= 16384
    error_message = "function_memory_in_mbs must be between 128 and 16384"
  }
}

variable "function_timeout_in_seconds" {
  type        = number
  description = "Timeout for function execution in seconds"
  default     = 60

  validation {
    condition     = var.function_timeout_in_seconds >= 30 && var.function_timeout_in_seconds <= 3600
    error_message = "function_timeout_in_seconds must be between 30 and 3600"
  }
}

variable "discovery_compartment_ocid" {
  type        = string
  description = "Optional compartment OCID to query for Exadata VM clusters / DB nodes. Defaults to compartment_ocid if empty."
  default     = ""
}

variable "vm_cluster_name" {
  type        = string
  description = "Optional VM cluster display name to scope the SSH check to a single cluster. Empty checks all clusters in the compartment."
  default     = ""
}

variable "ssh_check_port" {
  type        = number
  description = "SSH port to check on remote hosts"
  default     = 22

  validation {
    condition     = var.ssh_check_port > 0 && var.ssh_check_port < 65536
    error_message = "ssh_check_port must be a valid port number (1-65535)"
  }
}

variable "ssh_check_timeout_seconds" {
  type        = number
  description = "Timeout in seconds for SSH connection attempts"
  default     = 10

  validation {
    condition     = var.ssh_check_timeout_seconds > 0
    error_message = "ssh_check_timeout_seconds must be greater than 0"
  }
}

variable "log_level" {
  type        = string
  description = "Python logging level (DEBUG, INFO, WARNING, ERROR)"
  default     = "INFO"

  validation {
    condition     = contains(["DEBUG", "INFO", "WARNING", "ERROR"], var.log_level)
    error_message = "log_level must be one of: DEBUG, INFO, WARNING, ERROR"
  }
}

variable "tags" {
  type        = map(string)
  description = "Free-form tags to apply to resources"
  default = {
    created_by = "Terraform"
  }
}


variable "name_suffix" {
  type        = string
  description = "Optional suffix appended to the function display name, e.g. \"-e1c1\", so multiple per-cluster instances in one environment have distinct names. Empty = single instance (default)."
  default     = ""
}

variable "ssh_check_target" {
  type        = string
  description = "Which node address ssh-check probes: \"admin\" (default, <hostname>.<ssh_check_domain> where sshd listens), \"primary\" (client-VNIC IP), or \"vip\" (node VIP)."
  default     = "admin"
}

variable "ssh_check_domain" {
  type        = string
  description = "Admin DNS domain appended to the node hostname when ssh_check_target = admin."
  default     = "admin.example.internal"
}
