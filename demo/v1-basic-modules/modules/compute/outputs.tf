output "instance_id" {
  value = openstack_compute_instance_v2.instance.id
}

output "floating_ip" {
  value = openstack_networking_floatingip_v2.fip.address
}