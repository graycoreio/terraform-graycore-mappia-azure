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
    max_count         = number
    min_count         = number
    vm_size           = string
    name              = string
    set_max_map_count = bool
    zones             = optional(list(string))
  })

  description = "AKS default node pool configuration"
}

variable "extra_node_pools" {
  type = list(object({
    max_count         = number
    min_count         = number
    vm_size           = string
    name              = string
    set_max_map_count = bool
    zones             = optional(list(string))
  }))

  description = "AKS extra node pool configuration"

  default = []
}

variable "public_ip_name" {
  type        = string
  description = "Public Ip resource name"
}

variable "domain_name_label" {
  type        = string
  description = "Public Ip domain name label"
}

variable "public_ip_zones" {
  type        = list(string)
  description = "Public Ip zones"
}

variable "oms_log_analytics_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace which the OMS Agent should send data to."
}