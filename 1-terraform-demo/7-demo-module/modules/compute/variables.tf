variable "name_prefix" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "flavor_name" {
  type = string
}

variable "image_id" {
  type = string
}

variable "network_id" {
  type = string
}

variable "secgroup_name" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "volume_ids" {
  type = list(string)
}

variable "external_pool" {
  type = string
}

variable "tags" {
  type    = list(string)
  default = []
}
