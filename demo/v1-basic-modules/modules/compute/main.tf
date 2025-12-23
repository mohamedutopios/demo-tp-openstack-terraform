resource "openstack_compute_keypair_v2" "keypair" {
  name       = "demo-keypair"
  public_key = file(var.ssh_public_key_path)
}

resource "openstack_compute_instance_v2" "instance" {
  name            = "demo-instance"
  image_id        = var.image_id
  flavor_name     = var.flavor_name
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = [var.secgroup_name]

  network {
    uuid = var.network_id
  }
}

resource "openstack_networking_floatingip_v2" "fip" {
  pool = "public1"
}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.instance.id
}