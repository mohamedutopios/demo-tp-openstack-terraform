resource "openstack_blockstorage_volume_v3" "myvol" {
  name = "myvol"
  size = 1
}

resource "openstack_compute_instance_v2" "myinstance" {
  name            = "myinstance"
  image_id        = "dd490254-a972-4f23-b987-7b389856dff5"
  flavor_id       = "2"
  key_pair        = "mykey"
  security_groups = ["default"]

  network {
    name = "demo-net"
  }
}

resource "openstack_compute_volume_attach_v2" "attached" {
  instance_id = openstack_compute_instance_v2.myinstance.id
  volume_id   = openstack_blockstorage_volume_v3.myvol.id
}