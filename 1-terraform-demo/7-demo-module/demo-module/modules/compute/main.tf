resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.keypair_name
  public_key = file(var.public_key_path)
}

resource "openstack_compute_instance_v2" "instance" {
  count           = var.instance_count
  name            = "${var.name_prefix}-vm-${count.index}"
  image_id        = var.image_id
  flavor_name     = var.flavor_name
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = [var.secgroup_name]

  network {
    uuid = var.network_id
  }

  tags = var.tags
}

resource "openstack_compute_volume_attach_v2" "attach" {
  count       = var.instance_count
  instance_id = openstack_compute_instance_v2.instance[count.index].id
  volume_id   = var.volume_ids[count.index]
}

resource "openstack_networking_floatingip_v2" "fip" {
  count = var.instance_count
  pool  = var.external_pool
  tags  = var.tags
}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  count       = var.instance_count
  floating_ip = openstack_networking_floatingip_v2.fip[count.index].address
  instance_id = openstack_compute_instance_v2.instance[count.index].id
}
