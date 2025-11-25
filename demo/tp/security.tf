
resource "openstack_networking_secgroup_v2" "sg_public" {
  name        = "sg_nginx_public"
  description = "Autorise SSH et HTTP depuis Internet"
}


resource "openstack_networking_secgroup_rule_v2" "rule_ssh_public" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_public.id
}


resource "openstack_networking_secgroup_rule_v2" "rule_icmp_public" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_public.id
}

resource "openstack_networking_secgroup_rule_v2" "rule_http_public" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_public.id
}


resource "openstack_networking_secgroup_v2" "sg_private" {
  name        = "sg_internal_private"
  description = "Autorise le trafic interne et le ping"
}


resource "openstack_networking_secgroup_rule_v2" "rule_ssh_internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = openstack_networking_subnet_v2.public_subnet.cidr 
  security_group_id = openstack_networking_secgroup_v2.sg_private.id
}


resource "openstack_networking_secgroup_rule_v2" "rule_icmp_internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = openstack_networking_subnet_v2.public_subnet.cidr
  security_group_id = openstack_networking_secgroup_v2.sg_private.id
}