output "instance_ids" {
  value = openstack_compute_instance_v2.instance[*].id
}

output "instance_names" {
  value = openstack_compute_instance_v2.instance[*].name
}

output "private_ips" {
  value = openstack_compute_instance_v2.instance[*].access_ip_v4
}

output "floating_ips" {
  value = openstack_networking_floatingip_v2.fip[*].address
}

output "instances" {
  value = {
    for i, instance in openstack_compute_instance_v2.instance : instance.name => {
      id          = instance.id
      private_ip  = instance.access_ip_v4
      floating_ip = openstack_networking_floatingip_v2.fip[i].address
    }
  }
}
