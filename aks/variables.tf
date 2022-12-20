variable "rg_name" {
  type        = string
  description = "Azure resource group name"
}

variable "location" {
  type        = string
  description = "Location to create the kubernetes cluster"
}

variable "name" {
  type        = string
  description = "AKS resource name"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}

variable "dns_prefix" {
  type        = string
  description = "AKS resource name"
}

variable "default_node_pool" {
  type = object({
    max_count = number
    min_count = number
    vm_size   = string
    name      = string
    set_max_map_count = bool
  })

  description = "AKS default node pool configuration"
}

variable "extra_node_pools" {
  type = list(object({
    max_count = number
    min_count = number
    vm_size   = string
    name      = string
    set_max_map_count = bool
  }))

  description = "AKS extra node pool configuration"

  default = []
}
