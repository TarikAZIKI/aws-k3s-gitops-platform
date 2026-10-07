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

variable "instance_type" {
  description = "Type d'instance EC2."
  type        = string
  default     = "t3.medium"
}

variable "admin_cidr" {
  description = "Ton IP publique en /32. Fournie automatiquement par le Makefile."
  type        = string
}

variable "ssh_public_key_path" {
  description = "Chemin de la clé publique SSH autorisée sur l'instance."
  type        = string
  default     = "~/.ssh/devops-platform.pub"
}
