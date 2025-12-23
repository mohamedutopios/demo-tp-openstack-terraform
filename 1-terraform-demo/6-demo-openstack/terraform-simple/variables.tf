# Authentication OpenStack
variable "auth_url" {
  description = "URL d'authentification OpenStack"
  type        = string
}

variable "region" {
  description = "Région OpenStack"
  type        = string
  default     = "RegionOne"
}

variable "tenant_name" {
  description = "Nom du projet OpenStack"
  type        = string
}

variable "user_name" {
  description = "Nom d'utilisateur"
  type        = string
}

variable "password" {
  description = "Mot de passe"
  type        = string
  sensitive   = true
}

# Instance
variable "instance_name" {
  description = "Nom de l'instance"
  type        = string
  default     = "nginx-server"
}

variable "flavor_name" {
  description = "Flavor de l'instance"
  type        = string
  default     = "m1.small"
}

variable "image_name" {
  description = "Nom de l'image"
  type        = string
  default     = "Ubuntu 22.04"
}

# Réseau
variable "public_network" {
  description = "Nom du réseau public"
  type        = string
  default     = "public1"
}

variable "private_cidr" {
  description = "CIDR du réseau privé"
  type        = string
  default     = "192.168.100.0/24"
}

# SSH
variable "ssh_public_key" {
  description = "Clé publique SSH"
  type        = string
}
