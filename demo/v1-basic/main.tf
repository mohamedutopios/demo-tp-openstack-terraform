# Image
resource "openstack_images_image_v2" "ubuntu" {
  name             = "ubuntu-22.04"
  image_source_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  container_format = "bare"
  disk_format      = "qcow2"
}

# Network
resource "openstack_networking_network_v2" "network" {
  name           = "demo-network"
  admin_state_up = true
}

# Subnet
resource "openstack_networking_subnet_v2" "subnet" {
  name       = "demo-subnet"
  network_id = openstack_networking_network_v2.network.id
  cidr       = "10.0.1.0/24"
  ip_version = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

# Router
resource "openstack_networking_router_v2" "router" {
  name                = "demo-router"
  external_network_id = data.openstack_networking_network_v2.external.id
}

data "openstack_networking_network_v2" "external" {
  name = "public1"
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

# Security Group
resource "openstack_networking_secgroup_v2" "secgroup" {
  name = "demo-secgroup"
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

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# Volume
resource "openstack_blockstorage_volume_v3" "volume" {
  name = "demo-volume"
  size = 10
}

# Keypair
resource "openstack_compute_keypair_v2" "keypair" {
  name       = "demo-keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Instance
resource "openstack_compute_instance_v2" "instance" {
  name            = "demo-instance"
  image_id        = openstack_images_image_v2.ubuntu.id
  flavor_name     = "m1.small"
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = [openstack_networking_secgroup_v2.secgroup.name]

  network {
    uuid = openstack_networking_network_v2.network.id
  }
}

# Attach volume
resource "openstack_compute_volume_attach_v2" "attach" {
  instance_id = openstack_compute_instance_v2.instance.id
  volume_id   = openstack_blockstorage_volume_v3.volume.id
}

# Floating IP
resource "openstack_networking_floatingip_v2" "fip" {
  pool = "public1"
}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.instance.id
}
