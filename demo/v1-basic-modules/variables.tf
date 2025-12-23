variable "auth_url" {}
variable "project_name" {}
variable "username" {}
variable "password" {}
variable "region" {}

variable "external_network_name" {
  default = "public1"
}

variable "image_name" {
  default = "ubuntu-22.04"
}

variable "image_url" {
  default = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "flavor_name" {
  default = "m1.small"
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}