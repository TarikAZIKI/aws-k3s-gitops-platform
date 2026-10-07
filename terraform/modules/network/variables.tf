variable "name" {
  description = "Préfixe des noms de ressources."
  type        = string
}

variable "vpc_cidr" {
  description = "Plage d'adresses du VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Plage d'adresses du sous-réseau public."
  type        = string
  default     = "10.0.1.0/24"
}
