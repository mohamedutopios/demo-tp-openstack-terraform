# =============================================================================
# Network Outputs
# =============================================================================

output "network_public_id" {
  description = "ID du réseau public"
  value       = openstack_networking_network_v2.network_public.id
}

output "network_public_name" {
  description = "Nom du réseau public"
  value       = openstack_networking_network_v2.network_public.name
}

output "network_private_id" {
  description = "ID du réseau privé"
  value       = openstack_networking_network_v2.network_private.id
}

output "network_private_name" {
  description = "Nom du réseau privé"
  value       = openstack_networking_network_v2.network_private.name
}

output "public_subnet_id" {
  description = "ID du subnet public"
  value       = openstack_networking_subnet_v2.public_subnet.id
}

output "public_subnet_cidr" {
  description = "CIDR du subnet public"
  value       = openstack_networking_subnet_v2.public_subnet.cidr
}

output "private_subnet_id" {
  description = "ID du subnet privé"
  value       = openstack_networking_subnet_v2.private_subnet.id
}

output "private_subnet_cidr" {
  description = "CIDR du subnet privé"
  value       = openstack_networking_subnet_v2.private_subnet.cidr
}

# =============================================================================
# Router Outputs
# =============================================================================

output "router_id" {
  description = "ID du routeur"
  value       = openstack_networking_router_v2.router.id
}

output "router_name" {
  description = "Nom du routeur"
  value       = openstack_networking_router_v2.router.name
}

# =============================================================================
# VM1 Outputs (Nginx)
# =============================================================================

output "vm1_id" {
  description = "ID de la VM1 (Nginx)"
  value       = openstack_compute_instance_v2.vm1_nginx.id
}

output "vm1_name" {
  description = "Nom de la VM1"
  value       = openstack_compute_instance_v2.vm1_nginx.name
}

output "vm1_private_ip" {
  description = "IP privée de la VM1"
  value       = openstack_networking_port_v2.vm1_port.all_fixed_ips[0]
}

output "vm1_floating_ip" {
  description = "IP publique de la VM1"
  value       = openstack_networking_floatingip_v2.vm1_fip.address
}

output "vm1_security_group_id" {
  description = "ID du security group VM1"
  value       = openstack_networking_secgroup_v2.sg_vm1.id
}

# =============================================================================
# VM2 Outputs
# =============================================================================

output "vm2_id" {
  description = "ID de la VM2"
  value       = openstack_compute_instance_v2.vm2_private.id
}

output "vm2_name" {
  description = "Nom de la VM2"
  value       = openstack_compute_instance_v2.vm2_private.name
}

output "vm2_private_ip" {
  description = "IP privée de la VM2"
  value       = openstack_networking_port_v2.vm2_port.all_fixed_ips[0]
}

output "vm2_security_group_id" {
  description = "ID du security group VM2"
  value       = openstack_networking_secgroup_v2.sg_vm2.id
}

# =============================================================================
# Access Outputs
# =============================================================================

output "nginx_url" {
  description = "URL de la page Nginx"
  value       = "http://${openstack_networking_floatingip_v2.vm1_fip.address}"
}

output "ssh_vm1" {
  description = "Commande SSH pour VM1"
  value       = "ssh ubuntu@${openstack_networking_floatingip_v2.vm1_fip.address}"
}

output "ping_command" {
  description = "Commande ping de VM1 vers VM2"
  value       = "ping ${openstack_networking_port_v2.vm2_port.all_fixed_ips[0]}"
}

# =============================================================================
# Summary Output
# =============================================================================

output "infrastructure_summary" {
  description = "Résumé de l'infrastructure"
  value = {
    networks = {
      public = {
        name   = openstack_networking_network_v2.network_public.name
        subnet = var.public_subnet_cidr
      }
      private = {
        name   = openstack_networking_network_v2.network_private.name
        subnet = var.private_subnet_cidr
      }
    }
    router = openstack_networking_router_v2.router.name
    vms = {
      vm1_nginx = {
        name       = openstack_compute_instance_v2.vm1_nginx.name
        os         = var.vm1_image
        private_ip = openstack_networking_port_v2.vm1_port.all_fixed_ips[0]
        public_ip  = openstack_networking_floatingip_v2.vm1_fip.address
      }
      vm2_private = {
        name       = openstack_compute_instance_v2.vm2_private.name
        os         = var.vm2_image
        private_ip = openstack_networking_port_v2.vm2_port.all_fixed_ips[0]
      }
    }
  }
}
