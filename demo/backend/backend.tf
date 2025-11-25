terraform {
  backend "s3" {
    bucket         = "mohamed-formation"
    key            = "openstack/prod/terraform.tfstate"
    region         = "eu-west-3"
  }
}