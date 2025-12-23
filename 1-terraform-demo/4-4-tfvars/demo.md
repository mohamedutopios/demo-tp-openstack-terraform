Parfait 👍
On repart **strictement avec `null_resource`**, **zéro `terraform_data`**, et on te fait **LA DÉMO COMPLÈTE**, **canonique**, **pédagogique**, **exploitable en formation**, avec :

* `terraform.tfvars`
* `dev.tfvars`
* `prod.tfvars`
* découpage clair
* logique dans `locals`
* **anti-patterns**
* **TP final**

👉 **Rien de moderne “à côté”**, uniquement **`null_resource`**, comme tu l’as demandé.

---

# 🧱 ARCHITECTURE FINALE DU PROJET

```
terraform-nullresource-demo/
├── main.tf
├── locals.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── dev.tfvars
└── prod.tfvars
```

---

# 1️⃣ variables.tf — INTERFACE UTILISATEUR

```hcl
variable "env" {
  description = "Environnement cible"
  type        = string
}

variable "app_name" {
  description = "Nom de l'application"
  type        = string
}

variable "version" {
  description = "Version applicative"
  type        = string
}

variable "replicas" {
  description = "Nombre de replicas"
  type        = number
}
```

📌 **Aucune logique ici**
📌 Juste ce que l’utilisateur a le droit de fournir

---

# 2️⃣ terraform.tfvars — VALEURS PAR DÉFAUT

📌 Chargé **automatiquement**

```hcl
env       = "dev"
app_name = "orders"
version  = "1.0.0"
replicas = 1
```

👉 Permet de faire :

```bash
terraform apply
```

---

# 3️⃣ dev.tfvars — OVERRIDE DEV

```hcl
env       = "dev"
replicas = 1
```

---

# 4️⃣ prod.tfvars — OVERRIDE PROD

```hcl
env       = "prod"
replicas = 3
```

---

# 5️⃣ locals.tf — LOGIQUE MÉTIER (LE CERVEAU)

```hcl
locals {

  # Identité normalisée
  app_id = "${var.app_name}-${var.env}"

  # Règle métier : pas de déploiement en DEV
  allow_deploy = var.env == "prod"

  # Configuration complète
  config = {
    name     = local.app_id
    version  = var.version
    replicas = var.replicas
  }

  # Hash pour détecter un changement
  config_hash = sha1(jsonencode(local.config))
}
```

📌 **Toute la logique est ici**
📌 Aucun effet de bord
📌 Aucun accès au cloud

---

# 6️⃣ main.tf — ACTION AVEC `null_resource`

```hcl
terraform {
  required_version = ">= 1.3.0"
}
```

```hcl
resource "null_resource" "deploy_app" {

  # 🔒 Blocage en DEV
  count = local.allow_deploy ? 1 : 0

  # 🔁 Déclencheur intelligent
  triggers = {
    config_hash = local.config_hash
  }

  provisioner "local-exec" {
    command = <<EOT
echo "🚀 Déploiement ${local.config.name}"
echo "📦 Version   : ${local.config.version}"
echo "🔁 Replicas  : ${local.config.replicas}"
echo "🔐 Hash      : ${local.config_hash}"
EOT
  }
}
```

📌 **Quand l’action s’exécute ?**

* uniquement si `env = prod`
* uniquement si `config_hash` change

---

# 7️⃣ outputs.tf — VISIBILITÉ

```hcl
output "application_id" {
  value = local.app_id
}

output "deploy_allowed" {
  value = local.allow_deploy
}

output "config_hash" {
  value = local.config_hash
}
```

---

# 8️⃣ COMMANDES DE TEST (À FAIRE EN FORMATION)

### ▶️ Cas 1 — terraform.tfvars seul

```bash
terraform init
terraform apply
```

Résultat :

```
deploy_allowed = false
```

❌ aucune action exécutée

---

### ▶️ Cas 2 — DEV explicite

```bash
terraform apply -var-file=dev.tfvars
```

❌ toujours bloqué

---

### ▶️ Cas 3 — PROD

```bash
terraform apply -var-file=prod.tfvars
```

✅ exécution du `null_resource`

---

### ▶️ Cas 4 — Changement de version

```bash
terraform apply -var-file=prod.tfvars -var="version=2.0.0"
```

🔁 `null_resource` détruit / recréé
🔁 action relancée automatiquement

---

# ⚠️ ANTI-PATTERNS À ENSEIGNER (IMPORTANT)

## ❌ Logique dans tfvars

```hcl
replicas = env == "prod" ? 3 : 1   # ❌
```

---

## ❌ locals comme variables utilisateur

```hcl
locals {
  env = "prod"   # ❌ non overridable
}
```

---

## ❌ duplication

```hcl
app_name = "orders-prod"  # ❌
```

---

## ❌ triggers sans hash

```hcl
triggers = {
  version = var.version
}
```

👉 fragile
👉 préférer `sha1(jsonencode(...))`

---

# 🎓 TP COMPLET POUR FORMATION

## 🎯 ÉNONCÉ

> Vous devez :

1. Gérer `dev` et `prod` via `tfvars`
2. Bloquer le déploiement en `dev`
3. Déployer uniquement en `prod`
4. Relancer le déploiement si la version change
5. Utiliser `null_resource`
6. Exposer les résultats via `outputs`

👉 **Le projet ci-dessus EST le corrigé officiel**

---

# 🧠 MODÈLE MENTAL FINAL (À FAIRE RETENIR)

```
terraform.tfvars / dev.tfvars / prod.tfvars
            ↓
        variables.tf
            ↓
         locals.tf   (logique)
            ↓
        null_resource (action)
            ↓
         outputs.tf
```

---

Si tu veux la suite :

* 🧱 **multi-null_resource avec dépendances**
* 🧪 **CI/CD réel (Docker / kubectl / Ansible)**
* 🧠 **quiz Terraform spécial null_resource**
* 📝 **sujet d’examen + barème**
* ⚠️ **quand NE PAS utiliser null_resource**

Dis-moi 👍
