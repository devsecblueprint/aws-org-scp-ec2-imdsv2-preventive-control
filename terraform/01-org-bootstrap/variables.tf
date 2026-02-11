variable "ou_name" {
  type        = string
  description = "Name of the Organizational Unit (OU) to create for labs."
  default     = "dsb-labs"

  validation {
    condition     = length(trim(var.ou_name, " ")) > 0
    error_message = "ou_name must not be empty."
  }
}
variable "create_sandbox_account" {
  type        = bool
  description = "Whether to create a sandbox member account inside the Organization for safe testing."
  default     = false
}

variable "sandbox_account_name" {
  type        = string
  description = "Name for the sandbox member account (only used if create_sandbox_account=true)."
  default     = "dsb-sandbox"

  validation {
    condition     = length(trim(var.sandbox_account_name, " ")) > 0
    error_message = "sandbox_account_name must not be empty."
  }
}

variable "sandbox_account_email" {
  type        = string
  description = "Unique email address for the sandbox AWS account (required if create_sandbox_account=true)."
  default     = ""
}
variable "sandbox_account_role_name" {
  type        = string
  description = "IAM Role name to create in the sandbox account for cross-account access (only used if create_sandbox_account=true)."
  default     = "OrganizationAccountAccessRole"

  validation {
    condition     = length(trim(var.sandbox_account_role_name, " ")) > 0
    error_message = "sandbox_account_role_name must not be empty."
  }
}
