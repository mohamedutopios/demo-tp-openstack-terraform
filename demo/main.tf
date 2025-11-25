resource "openstack_compute_instance_v2" "vm" {
  name        = "vm-no-key"
  image_name  = "cirros"
  flavor_name = "m1.tiny"

  network {
    name = "demo-net"
  }
}

