data "openstack_networking_network_v2" "external" {
  external = true
}

resource "openstack_networking_network_v2" "public_net" {
  name           = "network-public"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "public_subnet" {
  name       = "public-subnet1"
  network_id = openstack_networking_network_v2.public_net.id
  cidr       = "192.168.10.0/24" 
  ip_version = 4
}


resource "openstack_networking_network_v2" "private_net" {
  name           = "network-private"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_subnet" {
  name       = "private-subnet2"
  network_id = openstack_networking_network_v2.private_net.id
  cidr       = "192.168.20.0/24" 
  ip_version = 4
}


resource "openstack_networking_router_v2" "router" {
  name                = "main_router"
  external_network_id = data.openstack_networking_network_v2.external.id
  enable_snat         = true
}


resource "openstack_networking_router_interface_v2" "public_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.public_subnet.id
}

resource "openstack_networking_router_interface_v2" "private_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}