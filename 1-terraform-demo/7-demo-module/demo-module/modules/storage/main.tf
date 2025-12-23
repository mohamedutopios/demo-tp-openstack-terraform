resource "openstack_images_image_v2" "image" {
  name             = var.image_name
  image_source_url = var.image_url
  container_format = "bare"
  disk_format      = "qcow2"
  tags             = var.tags
}

resource "openstack_blockstorage_volume_v3" "volume" {
  count = var.volume_count
  name  = "${var.name_prefix}-volume-${count.index}"
  size  = var.volume_size
}
