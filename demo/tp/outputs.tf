output "nginx_public_ip" {
  description = "L'adresse IP publique pour accéder au serveur NGINX"
  value       = openstack_networking_floatingip_v2.fip_nginx.address
}

output "private_vm_ip" {
  description = "L'adresse IP privée de la VM interne"
  value       = openstack_compute_instance_v2.vm_private.network.0.fixed_ip_v4
}