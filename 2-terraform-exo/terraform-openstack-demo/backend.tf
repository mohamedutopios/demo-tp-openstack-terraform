# =============================================================================
# Backend Configuration - Stockage du tfstate
# =============================================================================

# Option 1: Backend local (par défaut)
# Le tfstate sera stocké localement dans terraform.tfstate

# Option 2: Backend Swift (Object Storage OpenStack)
# Décommentez pour utiliser Swift comme backend distant
/*
terraform {
  backend "swift" {
    container         = "terraform-state"
    archive_container = "terraform-state-archive"
    state_name        = "nginx-webserver.tfstate"
  }
}
*/

# Option 3: Backend S3 compatible (si vous avez un endpoint S3)
/*
terraform {
  backend "s3" {
    bucket                      = "terraform-states"
    key                         = "openstack/nginx-webserver/terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "https://s3.example.com"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
*/

# Option 4: Backend HTTP
/*
terraform {
  backend "http" {
    address        = "https://terraform-backend.example.com/state/nginx-webserver"
    lock_address   = "https://terraform-backend.example.com/state/nginx-webserver/lock"
    unlock_address = "https://terraform-backend.example.com/state/nginx-webserver/lock"
  }
}
*/
