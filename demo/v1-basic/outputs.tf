output "instance_id" {
  value = openstack_compute_instance_v2.instance.id
}

output "instance_ip" {
  value = openstack_compute_instance_v2.instance.access_ip_v4
}

output "floating_ip" {
  value = openstack_networking_floatingip_v2.fip.address
}

output "network_id" {
  value = openstack_networking_network_v2.network.id
}

output "subnet_id" {
  value = openstack_networking_subnet_v2.subnet.id
}

output "volume_id" {
  value = openstack_blockstorage_volume_v3.volume.id
}
