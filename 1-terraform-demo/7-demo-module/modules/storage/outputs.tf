output "image_id" {
  value = openstack_images_image_v2.image.id
}

output "volume_ids" {
  value = openstack_blockstorage_volume_v3.volume[*].id
}
