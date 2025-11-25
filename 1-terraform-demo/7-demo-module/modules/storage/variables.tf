variable "name_prefix" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "volume_count" {
  type    = number
  default = 1
}

variable "image_name" {
  type = string
}

variable "image_url" {
  type = string
}

variable "tags" {
  type    = list(string)
  default = []
}
