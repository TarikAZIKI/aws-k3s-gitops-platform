variable "project_name" {
  description = "Nom du projet, utilisé comme préfixe des ressources."
  type        = string
  default     = "devops-platform"
}

variable "region" {
  description = "Région AWS."
  type        = string
  default     = "eu-north-1"
}

variable "budget_limit_usd" {
  description = "Plafond mensuel du budget AWS, en dollars."
  type        = number
  default     = 5
}

variable "budget_alert_email" {
  description = "Adresse qui reçoit les alertes de budget."
  type        = string
}
