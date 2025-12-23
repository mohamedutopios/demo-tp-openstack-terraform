variable "name" {
  description = "Nom de l'instance"
  type        = string
}

variable "image_id" {
  description = "ID de l'image"
  type        = string
}

variable "flavor_id" {
  description = "ID du flavor"
  type        = string
}

variable "network_id" {
  description = "ID du réseau"
  type        = string
}

variable "security_group_name" {
  description = "Nom du security group"
  type        = string
}

variable "ssh_public_key" {
  description = "Clé publique SSH"
  type        = string
}

variable "public_network" {
  description = "Nom du réseau public pour floating IP"
  type        = string
}
