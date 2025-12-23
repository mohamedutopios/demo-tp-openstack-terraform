# =============================================================================
# Data Sources
# =============================================================================

data "openstack_networking_network_v2" "public" {
  name = var.public_network
}

data "openstack_images_image_v2" "ubuntu" {
  name        = var.image_name
  most_recent = true
}

data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}

# =============================================================================
# Module Network
# =============================================================================

module "network" {
  source = "./modules/network"

  name               = var.instance_name
  cidr               = var.private_cidr
  public_network_id  = data.openstack_networking_network_v2.public.id
}

# =============================================================================
# Module Security
# =============================================================================

module "security" {
  source = "./modules/security"

  name = var.instance_name
}

# =============================================================================
# Module Compute
# =============================================================================

module "compute" {
  source = "./modules/compute"

  name              = var.instance_name
  image_id          = data.openstack_images_image_v2.ubuntu.id
  flavor_id         = data.openstack_compute_flavor_v2.flavor.id
  network_id        = module.network.network_id
  security_group_name = module.security.security_group_name
  ssh_public_key    = var.ssh_public_key
  public_network    = var.public_network

  depends_on = [module.network]
}
