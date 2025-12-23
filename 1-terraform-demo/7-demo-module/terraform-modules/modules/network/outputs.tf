output "network_id" {
  description = "ID du réseau"
  value       = openstack_networking_network_v2.network.id
}

output "network_name" {
  description = "Nom du réseau"
  value       = openstack_networking_network_v2.network.name
}

output "subnet_id" {
  description = "ID du subnet"
  value       = openstack_networking_subnet_v2.subnet.id
}

output "router_id" {
  description = "ID du routeur"
  value       = openstack_networking_router_v2.router.id
}
