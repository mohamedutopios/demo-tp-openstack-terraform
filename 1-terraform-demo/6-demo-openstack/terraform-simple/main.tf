# =============================================================================
# Data Sources
# =============================================================================

data "openstack_networking_network_v2" "public" {
  name = var.public_network
}

data "openstack_images_image_v2" "ubuntu" {
  name        = var.image_name
  most_recent = true
}

data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}

# =============================================================================
# Réseau
# =============================================================================

resource "openstack_networking_network_v2" "network" {
  name           = "${var.instance_name}-network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnet" {
  name            = "${var.instance_name}-subnet"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = var.private_cidr
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

resource "openstack_networking_router_v2" "router" {
  name                = "${var.instance_name}-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

# =============================================================================
# Security Group
# =============================================================================

resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "${var.instance_name}-secgroup"
  description = "Security group pour serveur web"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# =============================================================================
# Keypair
# =============================================================================

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "${var.instance_name}-keypair"
  public_key = var.ssh_public_key
}

# =============================================================================
# Floating IP
# =============================================================================

resource "openstack_networking_floatingip_v2" "fip" {
  pool = var.public_network
}

# =============================================================================
# Instance
# =============================================================================

resource "openstack_compute_instance_v2" "instance" {
  name            = var.instance_name
  image_id        = data.openstack_images_image_v2.ubuntu.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = [openstack_networking_secgroup_v2.secgroup.name]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Bienvenue sur ${var.instance_name}</h1><p>Déployé avec Terraform sur OpenStack</p>" > /var/www/html/index.html
  EOF

  network {
    uuid = openstack_networking_network_v2.network.id
  }

  depends_on = [openstack_networking_router_interface_v2.router_interface]
}

# =============================================================================
# Association Floating IP
# =============================================================================

resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.instance.id
}
