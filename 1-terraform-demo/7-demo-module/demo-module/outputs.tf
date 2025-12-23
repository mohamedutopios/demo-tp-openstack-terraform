output "network_id" {
  value = module.network.network_id
}

output "subnet_id" {
  value = module.network.subnet_id
}

output "instance_ids" {
  value = module.compute.instance_ids
}

output "private_ips" {
  value = module.compute.private_ips
}

output "floating_ips" {
  value = module.compute.floating_ips
}

output "volume_ids" {
  value = module.storage.volume_ids
}

output "instances" {
  value = module.compute.instances
}
