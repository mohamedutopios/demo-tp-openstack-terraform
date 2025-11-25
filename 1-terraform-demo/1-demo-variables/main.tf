variable var_1 {
  type        = string
  default     = "var1"
  description = "default value for variable1"
}

output output_var1 {
  value       = var.var_1
}


output output_var2 {

    value = var.var_2

}

output "output_sub_props" {
    value = var.fisrt_object.props3.sub_props
}

output "variables_demo" {
    value = {
        count = var.vm_count
        backup = var.enable_backup
        tags = var.vm_tags
        subnet = var.subnets[0]
    }
}