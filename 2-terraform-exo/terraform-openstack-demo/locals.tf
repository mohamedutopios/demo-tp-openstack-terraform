# =============================================================================
# Locals - Valeurs calculées et réutilisables
# =============================================================================

locals {
  # Préfixe de nommage basé sur le projet et l'environnement
  name_prefix = "${var.project_name}-${var.environment}"

  # Noms des ressources avec préfixe
  network_name        = "${local.name_prefix}-network"
  subnet_name         = "${local.name_prefix}-subnet"
  router_name         = "${local.name_prefix}-router"
  security_group_name = "${local.name_prefix}-sg-web"
  keypair_name        = "${local.name_prefix}-keypair"
  instance_full_name  = "${local.name_prefix}-${var.instance_name}"
  floating_ip_name    = "${local.name_prefix}-fip"

  # Configuration réseau calculée
  gateway_ip    = cidrhost(var.private_network_cidr, 1)
  dhcp_start    = cidrhost(var.private_network_cidr, 10)
  dhcp_end      = cidrhost(var.private_network_cidr, 250)
  network_bits  = split("/", var.private_network_cidr)[1]

  # Tags communs pour toutes les ressources
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    },
    var.additional_tags
  )

  # Configuration Nginx
  nginx_port      = 80
  nginx_ssl_port  = 443
  nginx_root_path = "/var/www/html"

  # Script cloud-init pour installer Nginx
  cloud_init_script = templatefile("${path.module}/templates/cloud-init.yaml", {
    welcome_message = var.nginx_welcome_message
    hostname        = local.instance_full_name
    environment     = var.environment
    nginx_root      = local.nginx_root_path
  })

  # Ports de sécurité à ouvrir
  security_rules = {
    ssh = {
      description = "SSH access"
      port        = 22
      protocol    = "tcp"
      cidr        = var.allowed_ssh_cidr
    }
    http = {
      description = "HTTP access"
      port        = 80
      protocol    = "tcp"
      cidr        = var.allowed_http_cidr
    }
    https = {
      description = "HTTPS access"
      port        = 443
      protocol    = "tcp"
      cidr        = var.allowed_http_cidr
    }
    icmp = {
      description = "ICMP (ping)"
      port        = 0
      protocol    = "icmp"
      cidr        = "0.0.0.0/0"
    }
  }
}
