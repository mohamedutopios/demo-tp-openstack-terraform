# =============================================================================
# Outputs - Informations exportées après le déploiement
# =============================================================================

# -----------------------------------------------------------------------------
# Informations Instance
# -----------------------------------------------------------------------------

output "instance_id" {
  description = "ID de l'instance créée"
  value       = openstack_compute_instance_v2.nginx.id
}

output "instance_name" {
  description = "Nom de l'instance"
  value       = openstack_compute_instance_v2.nginx.name
}

output "instance_private_ip" {
  description = "Adresse IP privée de l'instance"
  value       = openstack_networking_port_v2.instance_port.all_fixed_ips[0]
}

output "instance_floating_ip" {
  description = "Adresse IP publique (flottante) de l'instance"
  value       = openstack_networking_floatingip_v2.fip.address
}

output "instance_status" {
  description = "État de l'instance"
  value       = openstack_compute_instance_v2.nginx.power_state
}

# -----------------------------------------------------------------------------
# Informations d'Accès
# -----------------------------------------------------------------------------

output "ssh_command" {
  description = "Commande SSH pour se connecter à l'instance"
  value       = "ssh -i <chemin_cle_privee> ubuntu@${openstack_networking_floatingip_v2.fip.address}"
}

output "web_url" {
  description = "URL du serveur web Nginx"
  value       = "http://${openstack_networking_floatingip_v2.fip.address}"
}

output "web_url_https" {
  description = "URL HTTPS du serveur web (si SSL configuré)"
  value       = "https://${openstack_networking_floatingip_v2.fip.address}"
}

# -----------------------------------------------------------------------------
# Informations Réseau
# -----------------------------------------------------------------------------

output "network_id" {
  description = "ID du réseau privé"
  value       = openstack_networking_network_v2.private.id
}

output "network_name" {
  description = "Nom du réseau privé"
  value       = openstack_networking_network_v2.private.name
}

output "subnet_id" {
  description = "ID du sous-réseau"
  value       = openstack_networking_subnet_v2.private.id
}

output "subnet_cidr" {
  description = "CIDR du sous-réseau"
  value       = openstack_networking_subnet_v2.private.cidr
}

output "router_id" {
  description = "ID du routeur"
  value       = openstack_networking_router_v2.router.id
}

output "public_network_id" {
  description = "ID du réseau public externe"
  value       = data.openstack_networking_network_v2.public.id
}

# -----------------------------------------------------------------------------
# Informations Sécurité
# -----------------------------------------------------------------------------

output "security_group_id" {
  description = "ID du security group"
  value       = openstack_networking_secgroup_v2.web.id
}

output "security_group_name" {
  description = "Nom du security group"
  value       = openstack_networking_secgroup_v2.web.name
}

output "keypair_name" {
  description = "Nom de la keypair SSH"
  value       = openstack_compute_keypair_v2.keypair.name
}

# -----------------------------------------------------------------------------
# Informations Image et Flavor
# -----------------------------------------------------------------------------

output "image_id" {
  description = "ID de l'image utilisée"
  value       = data.openstack_images_image_v2.ubuntu.id
}

output "image_name" {
  description = "Nom de l'image utilisée"
  value       = data.openstack_images_image_v2.ubuntu.name
}

output "flavor_id" {
  description = "ID du flavor utilisé"
  value       = data.openstack_compute_flavor_v2.instance.id
}

output "flavor_name" {
  description = "Nom du flavor utilisé"
  value       = data.openstack_compute_flavor_v2.instance.name
}

# -----------------------------------------------------------------------------
# Informations de Déploiement
# -----------------------------------------------------------------------------

output "environment" {
  description = "Environnement de déploiement"
  value       = var.environment
}

output "project_name" {
  description = "Nom du projet"
  value       = var.project_name
}

output "deployment_summary" {
  description = "Résumé du déploiement"
  value = {
    project        = var.project_name
    environment    = var.environment
    instance_name  = openstack_compute_instance_v2.nginx.name
    public_ip      = openstack_networking_floatingip_v2.fip.address
    private_ip     = openstack_networking_port_v2.instance_port.all_fixed_ips[0]
    network_cidr   = var.private_network_cidr
    image          = data.openstack_images_image_v2.ubuntu.name
    flavor         = data.openstack_compute_flavor_v2.instance.name
    volume_size_gb = var.instance_volume_size
  }
}

# -----------------------------------------------------------------------------
# Outputs pour intégration avec d'autres modules
# -----------------------------------------------------------------------------

output "network_details" {
  description = "Détails du réseau pour intégration avec d'autres modules"
  value = {
    network_id = openstack_networking_network_v2.private.id
    subnet_id  = openstack_networking_subnet_v2.private.id
    router_id  = openstack_networking_router_v2.router.id
    cidr       = var.private_network_cidr
  }
}

output "security_details" {
  description = "Détails de sécurité pour intégration avec d'autres modules"
  value = {
    security_group_id = openstack_networking_secgroup_v2.web.id
    keypair_name      = openstack_compute_keypair_v2.keypair.name
  }
}
