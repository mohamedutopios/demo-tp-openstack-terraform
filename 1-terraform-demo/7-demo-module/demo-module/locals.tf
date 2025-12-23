locals {
  name_prefix = "${var.project}-${var.environment}"
  
  common_tags = [for k, v in merge(var.tags, {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }) : "${k}=${v}"]

  secgroup_rules = [
    { protocol = "tcp", port_min = 22, port_max = 22, cidr = "0.0.0.0/0" },
    { protocol = "tcp", port_min = 80, port_max = 80, cidr = "0.0.0.0/0" },
    { protocol = "tcp", port_min = 443, port_max = 443, cidr = "0.0.0.0/0" },
    { protocol = "icmp", port_min = 0, port_max = 0, cidr = "0.0.0.0/0" }
  ]
}
