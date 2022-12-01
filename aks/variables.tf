variable "rg_name" {
  type        = string
  description = "Azure resource group name"
}

variable "rg_location" {
  type        = string
  description = "Azure resource group location"
}

variable "name" {
  type        = string
  description = "AKS resource name"
  default     = "mappia-aks"
}

variable "kubernetes_version" {
  type = string
  description = "Kubernetes version"
  default = "1.23"
}

variable "dns_prefix" {
  type        = string
  description = "AKS resource name"
  default     = "mappia-aks-dns"
}

variable "default_node_pool" {
  type = object({
    max_count = number
    min_count = number
    vm_size   = string
  })

  description = "AKS default node pool configuration"

  default = {
    max_count = 5
    min_count = 1
    vm_size   = "standard_b2s"
  }
}

variable "extra_node_pools" {
  type = list(object({
    max_count = number
    min_count = number
    vm_size   = string
    name      = string
  }))

  description = "AKS extra node pool configuration"

  default = []
}
