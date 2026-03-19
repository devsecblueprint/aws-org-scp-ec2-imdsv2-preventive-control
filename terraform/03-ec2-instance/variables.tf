variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "allowed_cidr" {
  type        = string
  description = "CIDR block allowed to access HTTP on the instance."
  default     = "0.0.0.0/0"
}
