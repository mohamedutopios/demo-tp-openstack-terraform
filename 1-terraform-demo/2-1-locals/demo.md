Parfait 👍
On va faire **PLUSIEURS DÉMOS VARIÉES**, **toutes avec le même découpage clair** :

```
demoX/
├── main.tf
├── locals.tf
└── outputs.tf
```

🎯 Objectif :
Voir **tous les usages réels de `locals`**, pas toujours les mêmes cas.

---

# 🧪 DÉMO 1 — Local = concaténation / normalisation

### Cas réel

👉 Construire un nom standardisé (app, env, région…)

## `locals.tf`

```hcl
locals {
  app    = "billing"
  env    = "dev"
  region = "eu-west"

  full_name = "${local.app}-${local.env}-${local.region}"
}
```

## `main.tf`

```hcl
resource "null_resource" "demo1" {
  provisioner "local-exec" {
    command = "echo Nom calculé : ${local.full_name}"
  }
}
```

## `outputs.tf`

```hcl
output "full_name" {
  value = local.full_name
}
```

---

# 🧪 DÉMO 2 — Local = table de configuration (map)

### Cas réel

👉 Paramètres différents selon l’environnement

## `locals.tf`

```hcl
locals {
  env = "prod"

  settings = {
    dev = {
      replicas = 1
      debug    = true
    }
    prod = {
      replicas = 3
      debug    = false
    }
  }

  selected = local.settings[local.env]
}
```

## `main.tf`

```hcl
resource "null_resource" "demo2" {
  provisioner "local-exec" {
    command = "echo Replicas=${local.selected.replicas} Debug=${local.selected.debug}"
  }
}
```

## `outputs.tf`

```hcl
output "selected_settings" {
  value = local.selected
}
```

---

# 🧪 DÉMO 3 — Local = condition métier

### Cas réel

👉 Autoriser / bloquer une action

## `locals.tf`

```hcl
locals {
  env        = "dev"
  allow_deploy = local.env != "dev"
}
```

## `main.tf`

```hcl
resource "null_resource" "demo3" {
  count = local.allow_deploy ? 1 : 0

  provisioner "local-exec" {
    command = "echo Déploiement autorisé"
  }
}
```

## `outputs.tf`

```hcl
output "deploy_allowed" {
  value = local.allow_deploy
}
```

---

# 🧪 DÉMO 4 — Local = liste + boucle (`for_each`)

### Cas réel

👉 Exécuter une action pour plusieurs services

## `locals.tf`

```hcl
locals {
  services = ["auth", "billing", "orders"]
}
```

## `main.tf`

```hcl
resource "null_resource" "demo4" {
  for_each = toset(local.services)

  provisioner "local-exec" {
    command = "echo Déploiement du service ${each.key}"
  }
}
```

## `outputs.tf`

```hcl
output "services" {
  value = local.services
}
```

---

# 🧪 DÉMO 5 — Local = génération de script

### Cas réel

👉 Générer dynamiquement un script Bash

## `locals.tf`

```hcl
locals {
  script = <<EOT
echo "Application: inventory"
echo "Environnement: prod"
EOT
}
```

## `main.tf`

```hcl
resource "null_resource" "demo5" {
  provisioner "local-exec" {
    command = local.script
  }
}
```

## `outputs.tf`

```hcl
output "script_genere" {
  value = local.script
}
```

---

# 🧪 DÉMO 6 — Local = déclencheur (hash)

### Cas réel

👉 Relancer une action quand une config change

## `locals.tf`

```hcl
locals {
  config = {
    version = "1.0"
    port    = 8080
  }

  config_hash = sha1(jsonencode(local.config))
}
```

## `main.tf`

```hcl
resource "null_resource" "demo6" {
  triggers = {
    hash = local.config_hash
  }

  provisioner "local-exec" {
    command = "echo Nouvelle config détectée"
  }
}
```

## `outputs.tf`

```hcl
output "config_hash" {
  value = local.config_hash
}
```

---

# 🧠 RÉCAP ULTRA CLAIR

## À quoi servent les `locals` ?

| Usage        | Exemple       |
| ------------ | ------------- |
| Calcul       | concaténation |
| Règles       | conditions    |
| Paramétrage  | maps          |
| Boucles      | listes        |
| Déclencheurs | hash          |
| Scripts      | heredoc       |

---

## Modèle mental définitif

```
locals.tf   = cerveau (logique, règles)
main.tf     = bras (actions)
outputs.tf  = vitrine (visibilité)
```

---

Si tu veux la suite, je peux te proposer :

* 🆕 **les mêmes démos avec `variables.tf`**
* ⚠️ **anti-patterns à ne JAMAIS faire**
* 🆚 **`null_resource` vs `terraform_data`**
* 🧪 **TP apprenant avec énoncé + correction**

Dis-moi 👍
