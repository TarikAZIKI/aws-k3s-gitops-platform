variable "project_name" {
  description = "Project name, used as a prefix for resource names."
  type        = string
  default     = "devops-platform"
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type. Must be Free Tier eligible on a free-plan account."
  type        = string
  default     = "m7i-flex.large"
}

variable "admin_cidr" {
  description = "Your public IP as a /32. Set automatically by the Makefile."
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key allowed on the instance."
  type        = string
  default     = "~/.ssh/devops-platform.pub"
}
