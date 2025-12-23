variable "name_prefix" {
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

variable "tags" {
  type    = list(string)
  default = []
}

variable "secgroup_rules" {
  type = list(object({
    protocol = string
    port_min = number
    port_max = number
    cidr     = string
  }))
}
