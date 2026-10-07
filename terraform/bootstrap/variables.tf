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

variable "budget_limit_usd" {
  description = "Monthly AWS budget limit, in USD."
  type        = number
  default     = 5
}

variable "budget_alert_email" {
  description = "Email address that receives budget alerts."
  type        = string
}
