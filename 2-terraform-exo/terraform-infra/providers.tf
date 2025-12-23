terraform {
  required_version = ">= 1.0.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54.0"
    }
  }
}

provider "openstack" {
  auth_url    = var.auth_url
  region      = var.region
  tenant_name = var.tenant_name
  user_name   = var.user_name
  password    = var.password
}
