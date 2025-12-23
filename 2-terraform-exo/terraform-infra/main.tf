# =============================================================================
# Data Sources
# =============================================================================

data "openstack_networking_network_v2" "external" {
  name = var.external_network
}

data "openstack_images_image_v2" "ubuntu_18" {
  name        = var.vm1_image
  most_recent = true
}

data "openstack_images_image_v2" "ubuntu_22" {
  name        = var.vm2_image
  most_recent = true
}

data "openstack_compute_flavor_v2" "vm1_flavor" {
  name = var.vm1_flavor
}

data "openstack_compute_flavor_v2" "vm2_flavor" {
  name = var.vm2_flavor
}

# =============================================================================
# Network Public
# =============================================================================

resource "openstack_networking_network_v2" "network_public" {
  name           = var.public_network_name
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "public_subnet" {
  name            = var.public_subnet_name
  network_id      = openstack_networking_network_v2.network_public.id
  cidr            = var.public_subnet_cidr
  ip_version      = 4
  gateway_ip      = local.public_gateway_ip
  dns_nameservers = var.dns_servers

  allocation_pool {
    start = local.public_dhcp_start
    end   = local.public_dhcp_end
  }
}

# =============================================================================
# Network Private
# =============================================================================

resource "openstack_networking_network_v2" "network_private" {
  name           = var.private_network_name
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "private_subnet" {
  name            = var.private_subnet_name
  network_id      = openstack_networking_network_v2.network_private.id
  cidr            = var.private_subnet_cidr
  ip_version      = 4
  gateway_ip      = local.private_gateway_ip
  dns_nameservers = var.dns_servers

  allocation_pool {
    start = local.private_dhcp_start
    end   = local.private_dhcp_end
  }
}

# =============================================================================
# Routeur
# =============================================================================

resource "openstack_networking_router_v2" "router" {
  name                = var.router_name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "router_public" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.public_subnet.id
}

resource "openstack_networking_router_interface_v2" "router_private" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}

# =============================================================================
# Security Group - VM1 (Nginx)
# =============================================================================

resource "openstack_networking_secgroup_v2" "sg_vm1" {
  name        = "${var.vm1_name}-secgroup"
  description = "Security group pour VM1 Nginx"
}

resource "openstack_networking_secgroup_rule_v2" "sg_vm1_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_vm1.id
}

resource "openstack_networking_secgroup_rule_v2" "sg_vm1_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_vm1.id
}

resource "openstack_networking_secgroup_rule_v2" "sg_vm1_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_vm1.id
}

resource "openstack_networking_secgroup_rule_v2" "sg_vm1_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = var.private_subnet_cidr
  security_group_id = openstack_networking_secgroup_v2.sg_vm1.id
}

# =============================================================================
# Security Group - VM2
# =============================================================================

resource "openstack_networking_secgroup_v2" "sg_vm2" {
  name        = "${var.vm2_name}-secgroup"
  description = "Security group pour VM2"
}

resource "openstack_networking_secgroup_rule_v2" "sg_vm2_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_vm2.id
}

resource "openstack_networking_secgroup_rule_v2" "sg_vm2_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = var.public_subnet_cidr
  security_group_id = openstack_networking_secgroup_v2.sg_vm2.id
}

# =============================================================================
# Keypair SSH
# =============================================================================

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "infra-keypair"
  public_key = var.ssh_public_key
}

# =============================================================================
# Floating IP pour VM1
# =============================================================================

resource "openstack_networking_floatingip_v2" "vm1_fip" {
  pool = var.external_network
}

# =============================================================================
# Port VM1
# =============================================================================

resource "openstack_networking_port_v2" "vm1_port" {
  name           = "${var.vm1_name}-port"
  network_id     = openstack_networking_network_v2.network_public.id
  admin_state_up = true

  security_group_ids = [openstack_networking_secgroup_v2.sg_vm1.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.public_subnet.id
  }
}

# =============================================================================
# Port VM2
# =============================================================================

resource "openstack_networking_port_v2" "vm2_port" {
  name           = "${var.vm2_name}-port"
  network_id     = openstack_networking_network_v2.network_private.id
  admin_state_up = true

  security_group_ids = [openstack_networking_secgroup_v2.sg_vm2.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.private_subnet.id
  }
}

# =============================================================================
# VM1 - Nginx (Ubuntu 18.04)
# =============================================================================

resource "openstack_compute_instance_v2" "vm1_nginx" {
  name      = var.vm1_name
  image_id  = data.openstack_images_image_v2.ubuntu_18.id
  flavor_id = data.openstack_compute_flavor_v2.vm1_flavor.id
  key_pair  = openstack_compute_keypair_v2.keypair.name
  user_data = local.vm1_user_data

  network {
    port = openstack_networking_port_v2.vm1_port.id
  }

  metadata = {
    role = "nginx"
    os   = "ubuntu-18.04"
  }

  depends_on = [
    openstack_networking_router_interface_v2.router_public
  ]
}

# =============================================================================
# VM2 - Ubuntu 22.04
# =============================================================================

resource "openstack_compute_instance_v2" "vm2_private" {
  name      = var.vm2_name
  image_id  = data.openstack_images_image_v2.ubuntu_22.id
  flavor_id = data.openstack_compute_flavor_v2.vm2_flavor.id
  key_pair  = openstack_compute_keypair_v2.keypair.name
  user_data = local.vm2_user_data

  network {
    port = openstack_networking_port_v2.vm2_port.id
  }

  metadata = {
    role = "private"
    os   = "ubuntu-22.04"
  }

  depends_on = [
    openstack_networking_router_interface_v2.router_private
  ]
}

# =============================================================================
# Association Floating IP - VM1
# =============================================================================

resource "openstack_networking_floatingip_associate_v2" "vm1_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.vm1_fip.address
  port_id     = openstack_networking_port_v2.vm1_port.id
}
