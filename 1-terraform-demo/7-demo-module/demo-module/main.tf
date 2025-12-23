module "network" {
  source = "./modules/network"

  name_prefix      = local.name_prefix
  subnet_cidr      = var.subnet_cidr
  dns_servers      = var.dns_servers
  external_network = var.external_network
  secgroup_rules   = local.secgroup_rules
  tags             = local.common_tags
}

module "storage" {
  source = "./modules/storage"
  
  name_prefix  = local.name_prefix
  volume_size  = var.volume_size
  volume_count = var.instance_count
  image_name   = "${local.name_prefix}-ubuntu"
  image_url    = var.image_url
  tags         = local.common_tags
}

module "compute" {
  source = "./modules/compute"

  name_prefix     = local.name_prefix
  instance_count  = var.instance_count
  flavor_name     = var.flavor_name
  image_id        = module.storage.image_id
  network_id      = module.network.network_id
  secgroup_name   = module.network.secgroup_name
  keypair_name    = "${local.name_prefix}-keypair"
  public_key_path = var.public_key_path
  volume_ids      = module.storage.volume_ids
  external_pool   = var.external_network
  tags            = local.common_tags
}
