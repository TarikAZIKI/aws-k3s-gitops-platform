variable "name" {
  description = "Prefix for resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC address range."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet address range."
  type        = string
  default     = "10.0.1.0/24"
}
