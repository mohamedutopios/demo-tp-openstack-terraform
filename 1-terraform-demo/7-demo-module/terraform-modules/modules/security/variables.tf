variable "name" {
  description = "Préfixe pour les ressources"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR autorisé pour SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "http_cidr" {
  description = "CIDR autorisé pour HTTP/HTTPS"
  type        = string
  default     = "0.0.0.0/0"
}
