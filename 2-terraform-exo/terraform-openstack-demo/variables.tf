# =============================================================================
# Variables OpenStack Authentication
# =============================================================================

variable "openstack_auth_url" {
  description = "URL d'authentification OpenStack (Keystone)"
  type        = string
}

variable "openstack_region" {
  description = "Région OpenStack"
  type        = string
  default     = "RegionOne"
}

variable "openstack_tenant_name" {
  description = "Nom du projet/tenant OpenStack"
  type        = string
}

variable "openstack_user_name" {
  description = "Nom d'utilisateur OpenStack"
  type        = string
}

variable "openstack_password" {
  description = "Mot de passe OpenStack"
  type        = string
  sensitive   = true
}

# =============================================================================
# Variables Instance
# =============================================================================

variable "instance_name" {
  description = "Nom de l'instance"
  type        = string
  default     = "nginx-webserver"
}

variable "instance_flavor" {
  description = "Flavor (taille) de l'instance"
  type        = string
  default     = "m1.small"
}

variable "instance_image" {
  description = "Nom de l'image Ubuntu à utiliser"
  type        = string
  default     = "Ubuntu 22.04"
}

variable "instance_volume_size" {
  description = "Taille du volume root en GB"
  type        = number
  default     = 20
}

# =============================================================================
# Variables Réseau
# =============================================================================

variable "public_network_name" {
  description = "Nom du réseau public externe"
  type        = string
  default     = "public1"
}

variable "private_network_cidr" {
  description = "CIDR du réseau privé"
  type        = string
  default     = "192.168.100.0/24"
}

variable "dns_nameservers" {
  description = "Serveurs DNS pour le sous-réseau"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

# =============================================================================
# Variables Sécurité
# =============================================================================

variable "ssh_public_key" {
  description = "Clé publique SSH pour l'accès à l'instance"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR autorisé pour l'accès SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_http_cidr" {
  description = "CIDR autorisé pour l'accès HTTP/HTTPS"
  type        = string
  default     = "0.0.0.0/0"
}

# =============================================================================
# Variables Application
# =============================================================================

variable "environment" {
  description = "Environnement de déploiement"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "L'environnement doit être dev, staging ou prod."
  }
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "demo"
}

variable "nginx_welcome_message" {
  description = "Message personnalisé pour la page d'accueil Nginx"
  type        = string
  default     = "Bienvenue sur le serveur Nginx déployé avec Terraform!"
}

# =============================================================================
# Variables Tags
# =============================================================================

variable "additional_tags" {
  description = "Tags additionnels pour les ressources"
  type        = map(string)
  default     = {}
}
