variable "auth_url" {
  type = string
}

variable "tenant_name" {
  type = string
}

variable "user_name" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "dns_servers" {
  type = list(string)
}

variable "external_network" {
  type = string
}

variable "flavor_name" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "image_url" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "tags" {
  type    = map(string)
  default = {}
}
