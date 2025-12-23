resource "openstack_compute_keypair_v2" "keypair" {
  name       = "${var.name}-keypair"
  public_key = var.ssh_public_key
}

resource "openstack_networking_floatingip_v2" "fip" {
  pool = var.public_network
}

resource "openstack_compute_instance_v2" "instance" {
  name            = var.name
  image_id        = var.image_id
  flavor_id       = var.flavor_id
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = [var.security_group_name]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Bienvenue sur ${var.name}</h1><p>Déployé avec Terraform sur OpenStack</p>" > /var/www/html/index.html
  EOF

  network {
    uuid = var.network_id
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.instance.id
}
