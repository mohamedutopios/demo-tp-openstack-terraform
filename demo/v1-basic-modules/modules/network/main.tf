resource "openstack_networking_network_v2" "network" {
  name = "demo-network"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "demo-subnet"
  network_id = openstack_networking_network_v2.network.id
  cidr       = "10.0.1.0/24"
  ip_version = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

resource "openstack_networking_router_v2" "router" {
  name                = "demo-router"
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}