variable "name" {
  description = "Préfixe pour les ressources"
  type        = string
}

variable "cidr" {
  description = "CIDR du réseau privé"
  type        = string
}

variable "public_network_id" {
  description = "ID du réseau public externe"
  type        = string
}

variable "dns_servers" {
  description = "Serveurs DNS"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}
