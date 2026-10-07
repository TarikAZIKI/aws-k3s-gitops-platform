variable "name" {
  description = "Préfixe des noms de ressources."
  type        = string
}

variable "vpc_id" {
  description = "VPC dans lequel créer le security group."
  type        = string
}

variable "subnet_id" {
  description = "Sous-réseau public de l'instance."
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2. 4 Go de RAM minimum pour k3s + ArgoCD + monitoring."
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size_gb" {
  description = "Taille du disque système, en Go."
  type        = number
  default     = 30
}

variable "admin_cidr" {
  description = "Seule plage d'adresses autorisée en SSH et sur l'API Kubernetes (ton IP en /32)."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr doit être un CIDR valide, et pas 0.0.0.0/0."
  }
}

variable "ssh_public_key" {
  description = "Contenu de la clé publique SSH autorisée sur l'instance."
  type        = string
}

variable "ssm_parameter_path" {
  description = "Préfixe des paramètres SSM que l'instance a le droit de lire (ex. /devops-platform)."
  type        = string
}
