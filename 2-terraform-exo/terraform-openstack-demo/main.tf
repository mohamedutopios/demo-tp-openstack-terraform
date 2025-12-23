# =============================================================================
# Data Sources - Récupération des ressources existantes
# =============================================================================

# Récupération du réseau public externe
data "openstack_networking_network_v2" "public" {
  name = var.public_network_name
}

# Récupération de l'image Ubuntu 22.04
data "openstack_images_image_v2" "ubuntu" {
  name        = var.instance_image
  most_recent = true
}

# Récupération du flavor
data "openstack_compute_flavor_v2" "instance" {
  name = var.instance_flavor
}

# =============================================================================
# Réseau Privé
# =============================================================================

# Création du réseau privé
resource "openstack_networking_network_v2" "private" {
  name           = local.network_name
  admin_state_up = true
  description    = "Réseau privé pour ${var.project_name} - ${var.environment}"

  tags = [
    "project:${var.project_name}",
    "environment:${var.environment}",
    "managed-by:terraform"
  ]
}

# Création du sous-réseau
resource "openstack_networking_subnet_v2" "private" {
  name            = local.subnet_name
  network_id      = openstack_networking_network_v2.private.id
  cidr            = var.private_network_cidr
  ip_version      = 4
  gateway_ip      = local.gateway_ip
  dns_nameservers = var.dns_nameservers
  description     = "Sous-réseau pour ${var.project_name}"

  allocation_pool {
    start = local.dhcp_start
    end   = local.dhcp_end
  }

  tags = [
    "project:${var.project_name}",
    "environment:${var.environment}"
  ]
}

# =============================================================================
# Routeur - Connexion au réseau public
# =============================================================================

# Création du routeur
resource "openstack_networking_router_v2" "router" {
  name                = local.router_name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public.id
  description         = "Routeur pour ${var.project_name}"

  tags = [
    "project:${var.project_name}",
    "environment:${var.environment}"
  ]
}

# Attachement du routeur au sous-réseau privé
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private.id
}

# =============================================================================
# Security Group
# =============================================================================

# Création du security group
resource "openstack_networking_secgroup_v2" "web" {
  name        = local.security_group_name
  description = "Security group pour serveur web Nginx - ${var.environment}"

  tags = [
    "project:${var.project_name}",
    "environment:${var.environment}"
  ]
}

# Règles du security group (créées dynamiquement depuis locals)
resource "openstack_networking_secgroup_rule_v2" "ingress_rules" {
  for_each = local.security_rules

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.protocol == "icmp" ? null : each.value.port
  port_range_max    = each.value.protocol == "icmp" ? null : each.value.port
  remote_ip_prefix  = each.value.cidr
  security_group_id = openstack_networking_secgroup_v2.web.id
  description       = each.value.description
}

# =============================================================================
# Keypair SSH
# =============================================================================

resource "openstack_compute_keypair_v2" "keypair" {
  name       = local.keypair_name
  public_key = var.ssh_public_key
}

# =============================================================================
# Floating IP (IP publique)
# =============================================================================

resource "openstack_networking_floatingip_v2" "fip" {
  pool        = var.public_network_name
  description = "IP flottante pour ${local.instance_full_name}"

  tags = [
    "project:${var.project_name}",
    "environment:${var.environment}",
    "instance:${local.instance_full_name}"
  ]
}

# =============================================================================
# Port Réseau
# =============================================================================

resource "openstack_networking_port_v2" "instance_port" {
  name           = "${local.instance_full_name}-port"
  network_id     = openstack_networking_network_v2.private.id
  admin_state_up = true

  security_group_ids = [
    openstack_networking_secgroup_v2.web.id
  ]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.private.id
  }

  tags = [
    "project:${var.project_name}",
    "environment:${var.environment}"
  ]
}

# =============================================================================
# Instance de Calcul
# =============================================================================

resource "openstack_compute_instance_v2" "nginx" {
  name            = local.instance_full_name
  flavor_id       = data.openstack_compute_flavor_v2.instance.id
  key_pair        = openstack_compute_keypair_v2.keypair.name
  user_data       = local.cloud_init_script
  config_drive    = true

  # Utilisation d'un volume boot pour plus de flexibilité
  block_device {
    uuid                  = data.openstack_images_image_v2.ubuntu.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = var.instance_volume_size
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.instance_port.id
  }

  metadata = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
    role        = "webserver"
  }

  tags = [
    "project:${var.project_name}",
    "environment:${var.environment}",
    "role:webserver"
  ]

  # S'assurer que le réseau est prêt avant de créer l'instance
  depends_on = [
    openstack_networking_router_interface_v2.router_interface
  ]
}

# =============================================================================
# Association Floating IP
# =============================================================================

resource "openstack_networking_floatingip_associate_v2" "fip_association" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  port_id     = openstack_networking_port_v2.instance_port.id
}
