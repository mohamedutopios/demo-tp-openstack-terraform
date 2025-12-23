output "instance_id" {
  value = module.compute.instance_id
}

output "floating_ip" {
  value = module.compute.floating_ip
}

output "network_id" {
  value = module.network.network_id
}

output "subnet_id" {
  value = module.network.subnet_id
}