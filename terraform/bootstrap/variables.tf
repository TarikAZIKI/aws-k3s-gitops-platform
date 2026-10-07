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

variable "github_repository" {
  description = "GitHub repository (owner/name) allowed to run Terraform plans in AWS."
  type        = string
  default     = "TarikAZIKI/aws-k3s-gitops-platform"
}

variable "enable_github_oidc" {
  description = "Create the GitHub OIDC provider and the read-only plan role (blocked by SCP on new-experience accounts)."
  type        = bool
  default     = false
}
