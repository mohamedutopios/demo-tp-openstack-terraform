# Terraform OpenStack - Nginx Web Server Demo

Ce projet Terraform déploie une infrastructure complète sur OpenStack avec un serveur web Nginx sur Ubuntu 22.04.

## Architecture

```
                    ┌─────────────────────────────────────────────────────────┐
                    │                      OpenStack                           │
                    │                                                          │
   Internet         │    ┌─────────────┐       ┌─────────────────────────┐    │
       │            │    │   public1   │       │     Réseau Privé        │    │
       │            │    │  (externe)  │       │   192.168.100.0/24      │    │
       ▼            │    └──────┬──────┘       └───────────┬─────────────┘    │
  ┌─────────┐       │           │                          │                   │
  │ Floating│◄──────┼───────────┤                          │                   │
  │   IP    │       │           │         ┌────────────────┤                   │
  └─────────┘       │           ▼         │                │                   │
                    │    ┌─────────────┐  │    ┌───────────┴───────────┐      │
                    │    │   Router    │──┘    │     Ubuntu 22.04      │      │
                    │    └─────────────┘       │     + Nginx           │      │
                    │                          │     (m1.small)        │      │
                    │                          └───────────────────────┘      │
                    │                                                          │
                    └─────────────────────────────────────────────────────────┘
```

## Structure du Projet

```
terraform-openstack-demo/
├── backend.tf              # Configuration du backend tfstate
├── locals.tf               # Variables locales calculées
├── main.tf                 # Ressources principales OpenStack
├── outputs.tf              # Outputs exportés
├── providers.tf            # Configuration du provider OpenStack
├── variables.tf            # Définition des variables
├── terraform.tfvars.example # Exemple de fichier de variables
├── templates/
│   └── cloud-init.yaml     # Script d'initialisation de la VM
└── README.md               # Cette documentation
```

## Prérequis

- Terraform >= 1.0.0
- Accès à un cloud OpenStack
- Clé SSH générée
- Réseau public "public1" existant

## Installation

### 1. Cloner le projet

```bash
git clone <repository-url>
cd terraform-openstack-demo
```

### 2. Configurer les variables

```bash
# Copier le fichier d'exemple
cp terraform.tfvars.example terraform.tfvars

# Éditer avec vos valeurs
vim terraform.tfvars
```

### 3. Configurer l'authentification

**Option A: Variables d'environnement (recommandé)**

```bash
export OS_AUTH_URL="https://your-openstack.com:5000/v3"
export OS_REGION_NAME="RegionOne"
export OS_PROJECT_NAME="mon-projet"
export OS_USERNAME="mon-utilisateur"
export OS_PASSWORD="mon-mot-de-passe"
```

**Option B: Dans terraform.tfvars** (moins sécurisé)

```hcl
openstack_auth_url    = "https://your-openstack.com:5000/v3"
openstack_tenant_name = "mon-projet"
openstack_user_name   = "mon-utilisateur"
openstack_password    = "mon-mot-de-passe"
```

### 4. Ajouter votre clé SSH

Dans `terraform.tfvars`:

```hcl
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E... votre-clé-publique"
```

## Déploiement

```bash
# Initialiser Terraform
terraform init

# Voir le plan d'exécution
terraform plan

# Appliquer les changements
terraform apply

# Confirmer avec 'yes'
```

## Outputs

Après le déploiement, vous obtiendrez:

```bash
# Voir tous les outputs
terraform output

# IP publique
terraform output instance_floating_ip

# Commande SSH
terraform output ssh_command

# URL du serveur web
terraform output web_url
```

## Accès

### SSH
```bash
ssh -i ~/.ssh/id_rsa ubuntu@<floating-ip>
```

### Web
Ouvrez dans un navigateur: `http://<floating-ip>`

## Configuration du Backend distant

Pour stocker le tfstate de manière sécurisée, décommentez la section appropriée dans `backend.tf`:

### Swift (OpenStack Object Storage)
```hcl
terraform {
  backend "swift" {
    container  = "terraform-state"
    state_name = "nginx-webserver.tfstate"
  }
}
```

### S3 Compatible
```hcl
terraform {
  backend "s3" {
    bucket   = "terraform-states"
    key      = "openstack/nginx-webserver/terraform.tfstate"
    endpoint = "https://s3.example.com"
  }
}
```

## Nettoyage

```bash
# Détruire toutes les ressources
terraform destroy

# Confirmer avec 'yes'
```

## Personnalisation

### Changer la taille de l'instance

```hcl
instance_flavor = "m1.medium"
```

### Changer le message de bienvenue

```hcl
nginx_welcome_message = "Mon message personnalisé!"
```

### Restreindre l'accès SSH

```hcl
allowed_ssh_cidr = "203.0.113.0/24"  # Votre IP/réseau uniquement
```

## Variables

| Variable | Description | Défaut |
|----------|-------------|--------|
| `instance_name` | Nom de l'instance | `nginx-webserver` |
| `instance_flavor` | Taille de la VM | `m1.small` |
| `instance_image` | Image Ubuntu | `Ubuntu 22.04` |
| `environment` | Environnement | `dev` |
| `project_name` | Nom du projet | `demo` |
| `public_network_name` | Réseau public | `public1` |
| `private_network_cidr` | CIDR privé | `192.168.100.0/24` |

## Dépannage

### L'instance ne démarre pas
- Vérifiez que le flavor existe: `openstack flavor list`
- Vérifiez que l'image existe: `openstack image list`

### Pas de connexion SSH
- Vérifiez le security group: `openstack security group rule list`
- Vérifiez la floating IP: `openstack floating ip list`

### Nginx ne répond pas
- Connectez-vous en SSH et vérifiez: `systemctl status nginx`
- Consultez les logs cloud-init: `cat /var/log/cloud-init-output.log`

## Licence

MIT
