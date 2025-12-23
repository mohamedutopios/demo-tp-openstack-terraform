resource "openstack_images_image_v2" "this" {
  name             = var.name
  image_source_url = var.image_url
  container_format = "bare"
  disk_format      = "qcow2"
}