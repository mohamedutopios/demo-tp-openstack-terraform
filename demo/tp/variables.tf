variable "key_pair_name" {
  description = "Nom de la paire de clés SSH existante pour les VMs"
  type        = string
  default     = "tpkey" 
}

variable "flavor_name" {
  description = "Nom du 'flavor' (taille) des VMs (ex: m1.small)"
  type        = string
  default     = "m1.small"
}

variable "image_name" {
  description = "Nom de l'image Ubuntu à utiliser"
  type        = string
  default     = "ubuntu-20-04"
}