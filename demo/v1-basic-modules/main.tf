module "image" {
  source     = "./modules/image"
  name       = var.image_name
  image_url  = var.image_url
}

module "network" {
  source                = "./modules/network"
  external_network_name = var.external_network_name
}

module "security" {
  source = "./modules/security"
}

module "compute" {
  source              = "./modules/compute"
  image_id            = module.image.image_id
  network_id          = module.network.network_id
  secgroup_name       = module.security.secgroup_name
  flavor_name         = var.flavor_name
  ssh_public_key_path = var.ssh_public_key_path
}