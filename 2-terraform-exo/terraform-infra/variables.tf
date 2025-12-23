# =============================================================================
# Authentication OpenStack
# =============================================================================

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

# =============================================================================
# External Network
# =============================================================================

variable "external_network" {
  description = "Nom du réseau externe"
  type        = string
  default     = "external-network"
}

# =============================================================================
# Network Public
# =============================================================================

variable "public_network_name" {
  description = "Nom du réseau public"
  type        = string
  default     = "network-public"
}

variable "public_subnet_name" {
  description = "Nom du subnet public"
  type        = string
  default     = "public-subnet1"
}

variable "public_subnet_cidr" {
  description = "CIDR du subnet public"
  type        = string
  default     = "10.0.1.0/24"
}

# =============================================================================
# Network Private
# =============================================================================

variable "private_network_name" {
  description = "Nom du réseau privé"
  type        = string
  default     = "network-private"
}

variable "private_subnet_name" {
  description = "Nom du subnet privé"
  type        = string
  default     = "private-subnet2"
}

variable "private_subnet_cidr" {
  description = "CIDR du subnet privé"
  type        = string
  default     = "10.0.2.0/24"
}

# =============================================================================
# Router
# =============================================================================

variable "router_name" {
  description = "Nom du routeur"
  type        = string
  default     = "routeur"
}

# =============================================================================
# VM1 - Nginx (Ubuntu 18.04)
# =============================================================================

variable "vm1_name" {
  description = "Nom de la VM1 (Nginx)"
  type        = string
  default     = "vm-nginx"
}

variable "vm1_image" {
  description = "Image pour VM1"
  type        = string
  default     = "Ubuntu 18.04"
}

variable "vm1_flavor" {
  description = "Flavor pour VM1"
  type        = string
  default     = "m1.small"
}

# =============================================================================
# VM2 - Ubuntu 22.04
# =============================================================================

variable "vm2_name" {
  description = "Nom de la VM2"
  type        = string
  default     = "vm-private"
}

variable "vm2_image" {
  description = "Image pour VM2"
  type        = string
  default     = "Ubuntu 22.04"
}

variable "vm2_flavor" {
  description = "Flavor pour VM2"
  type        = string
  default     = "m1.small"
}

# =============================================================================
# SSH
# =============================================================================

variable "ssh_public_key" {
  description = "Clé publique SSH"
  type        = string
}

# =============================================================================
# DNS
# =============================================================================

variable "dns_servers" {
  description = "Serveurs DNS"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}
