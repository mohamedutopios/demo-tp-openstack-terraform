output "network_id" {
  value = openstack_networking_network_v2.network.id
}

output "subnet_id" {
  value = openstack_networking_subnet_v2.subnet.id
}

output "router_id" {
  value = openstack_networking_router_v2.router.id
}

output "secgroup_name" {
  value = openstack_networking_secgroup_v2.secgroup.name
}

output "secgroup_id" {
  value = openstack_networking_secgroup_v2.secgroup.id
}

output "external_network_id" {
  value = data.openstack_networking_network_v2.external.id
}
