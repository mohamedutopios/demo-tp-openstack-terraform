# =============================================================================
# Locals - Valeurs calculées
# =============================================================================

locals {
  # Calcul des IPs de gateway
  public_gateway_ip  = cidrhost(var.public_subnet_cidr, 1)
  private_gateway_ip = cidrhost(var.private_subnet_cidr, 1)

  # Pools DHCP
  public_dhcp_start  = cidrhost(var.public_subnet_cidr, 10)
  public_dhcp_end    = cidrhost(var.public_subnet_cidr, 250)
  private_dhcp_start = cidrhost(var.private_subnet_cidr, 10)
  private_dhcp_end   = cidrhost(var.private_subnet_cidr, 250)

  # Script cloud-init pour VM1 (Nginx)
  vm1_user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>NGINX - ${var.vm1_name}</title>
        <style>
            body { font-family: Arial; text-align: center; padding: 50px; background: #1a1a2e; color: #eee; }
            h1 { color: #00d9ff; }
            .info { background: #16213e; padding: 20px; border-radius: 10px; margin: 20px auto; max-width: 500px; }
        </style>
    </head>
    <body>
        <h1>🚀 Page Defaut NGINX</h1>
        <div class="info">
            <p><strong>Hostname:</strong> ${var.vm1_name}</p>
            <p><strong>OS:</strong> Ubuntu 18.04</p>
            <p><strong>Déployé avec:</strong> Terraform + OpenStack</p>
        </div>
    </body>
    </html>
    HTML
  EOF

  # Script cloud-init pour VM2
  vm2_user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y curl net-tools iputils-ping
  EOF

  # Règles Security Group pour VM1 (Nginx)
  sg_rules_vm1 = {
    ssh = {
      port     = 22
      protocol = "tcp"
      cidr     = "0.0.0.0/0"
    }
    http = {
      port     = 80
      protocol = "tcp"
      cidr     = "0.0.0.0/0"
    }
    https = {
      port     = 443
      protocol = "tcp"
      cidr     = "0.0.0.0/0"
    }
    icmp = {
      port     = 0
      protocol = "icmp"
      cidr     = var.private_subnet_cidr
    }
  }

  # Règles Security Group pour VM2
  sg_rules_vm2 = {
    ssh = {
      port     = 22
      protocol = "tcp"
      cidr     = "0.0.0.0/0"
    }
    icmp = {
      port     = 0
      protocol = "icmp"
      cidr     = var.public_subnet_cidr
    }
    all_internal = {
      port     = 0
      protocol = "-1"
      cidr     = var.private_subnet_cidr
    }
  }
}
