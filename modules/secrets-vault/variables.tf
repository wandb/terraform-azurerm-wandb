variable "k8s_subnet_ids" {
    description = "A list of virtual subnet ids which are allowed to access this vault"
    nullable = false
    type = list(string)
}

variable "namespace" {
    nullable = false
    type = string
}

variable "resource_group_name" {
    nullable = false
    type = string
}