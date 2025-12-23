output "instance_id" {
  description = "ID de l'instance"
  value       = openstack_compute_instance_v2.instance.id
}

output "instance_name" {
  description = "Nom de l'instance"
  value       = openstack_compute_instance_v2.instance.name
}

output "private_ip" {
  description = "IP privée"
  value       = openstack_compute_instance_v2.instance.access_ip_v4
}

output "floating_ip" {
  description = "IP publique"
  value       = openstack_networking_floatingip_v2.fip.address
}

output "web_url" {
  description = "URL du serveur web"
  value       = "http://${openstack_networking_floatingip_v2.fip.address}"
}

output "ssh_command" {
  description = "Commande SSH"
  value       = "ssh ubuntu@${openstack_networking_floatingip_v2.fip.address}"
}

output "network_id" {
  description = "ID du réseau"
  value       = openstack_networking_network_v2.network.id
}

output "security_group_id" {
  description = "ID du security group"
  value       = openstack_networking_secgroup_v2.secgroup.id
}
