# Network outputs
output "network_id" {
  description = "ID du réseau"
  value       = module.network.network_id
}

output "subnet_id" {
  description = "ID du subnet"
  value       = module.network.subnet_id
}

output "router_id" {
  description = "ID du routeur"
  value       = module.network.router_id
}

# Security outputs
output "security_group_id" {
  description = "ID du security group"
  value       = module.security.security_group_id
}

# Compute outputs
output "instance_id" {
  description = "ID de l'instance"
  value       = module.compute.instance_id
}

output "instance_name" {
  description = "Nom de l'instance"
  value       = module.compute.instance_name
}

output "private_ip" {
  description = "IP privée"
  value       = module.compute.private_ip
}

output "floating_ip" {
  description = "IP publique"
  value       = module.compute.floating_ip
}

output "web_url" {
  description = "URL du serveur web"
  value       = "http://${module.compute.floating_ip}"
}

output "ssh_command" {
  description = "Commande SSH"
  value       = "ssh ubuntu@${module.compute.floating_ip}"
}
