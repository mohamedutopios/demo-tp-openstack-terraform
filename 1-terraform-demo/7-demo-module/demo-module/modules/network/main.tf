data "openstack_networking_network_v2" "external" {
  name = var.external_network
}

resource "openstack_networking_network_v2" "network" {
  name           = "${var.name_prefix}-network"
  admin_state_up = true
  tags           = var.tags
}

resource "openstack_networking_subnet_v2" "subnet" {
  name            = "${var.name_prefix}-subnet"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = var.subnet_cidr
  ip_version      = 4
  dns_nameservers = var.dns_servers
  tags            = var.tags
}

resource "openstack_networking_router_v2" "router" {
  name                = "${var.name_prefix}-router"
  external_network_id = data.openstack_networking_network_v2.external.id
  tags                = var.tags
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

resource "openstack_networking_secgroup_v2" "secgroup" {
  name = "${var.name_prefix}-secgroup"
  tags = var.tags
}

resource "openstack_networking_secgroup_rule_v2" "rules" {
  count             = length(var.secgroup_rules)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = var.secgroup_rules[count.index].protocol
  port_range_min    = var.secgroup_rules[count.index].port_min
  port_range_max    = var.secgroup_rules[count.index].port_max
  remote_ip_prefix  = var.secgroup_rules[count.index].cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}
