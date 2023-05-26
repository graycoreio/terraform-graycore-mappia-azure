variable "address_space" {
  type        = list(string)
  description = "Virtual network adress space"
  default     = ["10.224.0.0/12"] # 10.224.0.0 - 10.239.255.255
}

variable "aks_name" {
  type        = string
  description = "Azure kubernetes system (AKS) resource name"
  default     = ""
}

variable "aks_subnet_address_space" {
  type        = list(string)
  description = "Virtual network adress space"
  default     = ["10.224.0.0/16"] # 10.224.0.0 - 10.224.255.255
}

variable "aks_subnet_name" {
  type        = string
  description = "AKS subnet name"
  default     = "aks-subnet"
}

variable "aks_network_profile" {
  type = object({
    network_plugin     = string
    service_cidr       = string
    dns_service_ip     = string
    docker_bridge_cidr = string
  })

  description = "AKS network profile, check terraform documentation https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#network_profile for each of the fields meaning"

  default = {
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    network_plugin     = "kubenet"
    service_cidr       = "10.0.0.0/16" # 172.16.0.0 -> 172.16.255.255
  }
}

variable "create_aks_subnet" {
  type        = bool
  description = "Create and link aks-subnet to aks. If you are using mappia for a pre-existing cluster you might want to keep the auto-generated subnet. In that case mark this as false"
  default     = true
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

  default = {
    name              = "agentpool"
    max_count         = 5
    min_count         = 4
    vm_size           = "Standard_B2s"
    set_max_map_count = true
  }
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix specified when creating the managed cluster"
  default     = ""
}

variable "domain_name_label" {
  type        = string
  description = "Label for the Domain Name. Will be used to make up the FQDN. Random value will be used if this is not provided"
  default     = ""
}

variable "encryption_key" {
  type        = string
  description = "Magento encryption key"
  sensitive   = true
  default     = ""
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

variable "helm_akvaks_chart_version" {
  type        = string
  description = "Akvaks chart version, latest will apply by default"
  default     = "0.3.3" # x-release-please-version
}

variable "helm_akvaks_values" {
  type        = string
  description = "AKV to AKS chart extra configuration file path"
  default     = "no-file"
}

variable "helm_ingress_name" {
  type        = string
  description = "Ingress chart name to be deployed"
  default     = "mappia-nginx"
}

variable "helm_ingress_namespace" {
  type        = string
  description = "Kubernetes namespace to deploy the chart to"
  default     = "ingress-nginx"
}

variable "helm_ingress_values" {
  type        = string
  description = "Ingress chart extra configuration file path"
  default     = "no-file"
}

variable "helm_mappia_chart_version" {
  type        = string
  description = "Mappia chart version, latest will apply by default"
  default     = "0.3.3" # x-release-please-version
}

variable "helm_mappia_name" {
  type        = string
  description = "Mappia chart name"
  default     = "mappia"
}

variable "helm_mappia_set_values" {
  type        = map(string)
  description = "Dict of custom values to be used as --set in helm command. E.g {\"installer.enabled\" = false }. These values will override the default set when keys collide"
  default     = {}
}

variable "helm_mappia_use_default_config" {
  type        = bool
  description = "Use pre-defined ingress/magento host configurations for mappia chart"
  default     = true
}

variable "helm_mappia_values" {
  type        = string
  description = "Mappia chart extra configuration file path"
  default     = "no-file"
}

variable "helm_pwd" {
  type        = string
  description = "Mappia's helm registry password"
  sensitive   = true
}

variable "helm_release_name" {
  type        = string
  description = "Mappia chart release name"
  default     = "mappia"
}

variable "helm_user" {
  type        = string
  description = "Mappia's helm registry user"
  sensitive   = true
}

variable "kubernetes_version" {
  type        = string
  description = "AKS kubernetes version"
  default     = "1.25"
}

variable "kv_name" {
  type        = string
  description = "[Optional] Keyvault resource name. If left empty a random name will be chosen"
  default     = ""
}

variable "kv_sku_name" {
  type        = string
  description = "The Name of the SKU used for this Key Vault. Possible values are 'standard' and 'premium'"
  default     = "standard"
}

variable "location" {
  type        = string
  description = "Location to create the resources. If unset, resource group location will be used"
  default     = ""
}

variable "oms_log_analytics_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace which the OMS Agent should send data to."
  default     = ""
}

variable "public_ip_name" {
  type        = string
  description = "Public Ip resource name"
  default     = "mappia-public-ip"
}

variable "public_ip_zones" {
  type        = list(string)
  description = "Public Ip zones"
  default     = []
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
  default     = "mappia"
}

variable "secrets" {
  type        = map(string)
  description = "Map of secrets that will be maitained by terraform e.g {\"my-secret\" = \"my-secret-value\" }"
  sensitive   = true
  default     = {}
}

variable "shared_cache_pwd" {
  type        = string
  description = "Magento shared cache password"
  sensitive   = true
  default     = ""
}

variable "sp_id" {
  type        = string
  description = "Service principal client Id"
}

variable "sp_object_id" {
  type        = string
  description = "Service principal object Id"
}

variable "sp_secret" {
  type        = string
  description = "Service principal client secret"
}

variable "sp_tenant_id" {
  type        = string
  description = "Service principal tenant id"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription id"
}

variable "virtual_network_name" {
  type        = string
  description = "Virtual network resource name. If not specified a random name will be generated"
  default     = ""
}
