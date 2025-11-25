variable var_2{
    description = "second variable"
    type = string 
    default = "var_2"
}

variable vm_count {
    description = "le nombre de vm à créer"
    type = number
    default = 3
}

variable "enable_backup" {
    type = bool
    default = false
}


variable "vm_tags" {
    type = map(string)
    default = {
        "env" = "dev"
        "owner" = "admin"
    }
}

variable "subnets" {
    type = list(string)
    default = ["subnet1", "subnet2"]
}


variable "fisrt_object" {
    description = "first object"
    type = object({
        props1 = string
        props2 = string
        props3 = object({
            sub_props = string
        }) 
    })
    default = {
        props1 = "value1"
        props2 = "value2"
        props3 = {
            sub_props = "value3"
        }
    }
}