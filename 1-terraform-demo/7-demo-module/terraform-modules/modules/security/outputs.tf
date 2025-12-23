output "security_group_id" {
  description = "ID du security group"
  value       = openstack_networking_secgroup_v2.secgroup.id
}

output "security_group_name" {
  description = "Nom du security group"
  value       = openstack_networking_secgroup_v2.secgroup.name
}
