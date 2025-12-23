# =============================================================================
# Provider Configuration
# =============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54.0"
    }
  }
}

# Provider OpenStack - utilise les variables d'environnement OS_* ou les variables Terraform
provider "openstack" {
  auth_url    = var.openstack_auth_url
  region      = var.openstack_region
  tenant_name = var.openstack_tenant_name
  user_name   = var.openstack_user_name
  password    = var.openstack_password
}
