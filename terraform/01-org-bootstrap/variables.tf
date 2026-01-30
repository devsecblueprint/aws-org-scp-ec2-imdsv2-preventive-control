variable "ou_name" {
  type        = string
  description = "Name of the Organizational Unit (OU) to create for labs."
  default     = "dsb-labs"

  validation {
    condition     = length(trim(var.ou_name)) > 0
    error_message = "ou_name must not be empty."
  }
}
