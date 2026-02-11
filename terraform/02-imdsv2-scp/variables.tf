variable "policy_name" {
  type        = string
  description = "Name for the SCP that enforces IMDSv2."
  default     = "deny-ec2-imdsv1"

  validation {
    condition     = length(trim(var.policy_name, " ")) > 0
    error_message = "policy_name must not be empty."
  }
}

variable "target_id" {
  type        = string
  description = "Organization root ID or OU ID to attach the SCP (e.g., r-xxxx or ou-xxxx-xxxxxxxx)."

  validation {
    condition     = length(trim(var.target_id, " ")) > 0
    error_message = "target_id must not be empty."
  }
}

variable "root_id" {
  type        = string
  description = "Organization root ID used to enable the SCP policy type (e.g., r-xxxx)."

  validation {
    condition     = length(trim(var.root_id, " ")) > 0
    error_message = "root_id must not be empty."
  }
}

variable "allowlisted_principal_arns" {
  type        = list(string)
  description = "Optional list of IAM principal ARNs exempt from this SCP (break-glass or automation)."
  default     = []
}
