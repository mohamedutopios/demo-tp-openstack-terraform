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

output "keypair_name" {
  description = "Nom de la keypair"
  value       = openstack_compute_keypair_v2.keypair.name
}
