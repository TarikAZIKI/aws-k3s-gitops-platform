variable "name" {
  description = "Prefix for resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC in which to create the security group."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet of the instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type. 8 GB of RAM leaves room for k3s, ArgoCD and the monitoring stack."
  type        = string
  default     = "m7i-flex.large"
}

variable "root_volume_size_gb" {
  description = "Root volume size, in GB."
  type        = number
  default     = 30
}

variable "admin_cidr" {
  description = "Only address range allowed on SSH and the Kubernetes API (your IP as a /32)."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr must be a valid CIDR, and not 0.0.0.0/0."
  }
}

variable "ssh_public_key" {
  description = "Content of the SSH public key allowed on the instance."
  type        = string
}

variable "ssm_parameter_path" {
  description = "Prefix of the SSM parameters the instance may read (e.g. /devops-platform)."
  type        = string
}
