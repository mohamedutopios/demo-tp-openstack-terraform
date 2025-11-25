auth_url    = "http://9.11.93.4:5000/v3"
tenant_name = "admin"
user_name   = "admin"
password    = "xMvLAtOwFyGnwVoT3V96mRZsxaMyxNE8HVQ4G8CJ"
region      = "RegionOne"

project     = "admin"
environment = "prod"

subnet_cidr      = "10.0.1.0/24"
dns_servers      = ["8.8.8.8", "8.8.4.4"]
external_network = "public1"

flavor_name     = "m1.small"
public_key_path = "~/.ssh/id_rsa.pub"
instance_count  = 3

image_url   = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
volume_size = 20

tags = {
  owner       = "devops"
  cost_center = "IT"
  team        = "platform"
}
