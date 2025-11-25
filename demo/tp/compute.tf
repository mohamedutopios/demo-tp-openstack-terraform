data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}

data "openstack_images_image_v2" "image" {
  name = var.image_name
}


resource "openstack_images_image_v2" "ubuntu2204" {
  name             = "ubuntu-22.04"
  image_source_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  container_format = "bare"
  disk_format      = "qcow2"
}

locals {
  nginx_user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    EOF
}


resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.key_pair_name
  public_key = file("~/.ssh/id_rsa.pub")
}


resource "openstack_compute_instance_v2" "vm_public" {
  name            = "vm-nginx-public"
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  image_id        = data.openstack_images_image_v2.image.id
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = [openstack_networking_secgroup_v2.sg_public.name]
  user_data       = local.nginx_user_data

  network {
    name = openstack_networking_network_v2.public_net.name
  }
  depends_on = [
    openstack_networking_router_interface_v2.public_interface
  ]

}

resource "openstack_networking_floatingip_v2" "fip_nginx" {
  pool = data.openstack_networking_network_v2.external.name
}

resource "openstack_compute_floatingip_associate_v2" "fip_associate_nginx" {
  floating_ip = openstack_networking_floatingip_v2.fip_nginx.address
  instance_id = openstack_compute_instance_v2.vm_public.id
}


resource "openstack_compute_instance_v2" "vm_private" {
  name            = "vm-backend-private"
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  image_id        = openstack_images_image_v2.ubuntu2204.id
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = [openstack_networking_secgroup_v2.sg_private.name]

  network {
    name = openstack_networking_network_v2.private_net.name
  }

  depends_on = [
    openstack_networking_router_interface_v2.private_interface 
  ]
}