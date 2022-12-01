variable "rg_name" {
  type = string
  description = "Azure resource group name"
}

variable "rg_location" {
  type = string
  description = "Azure resource group location"
}

variable "tenant_id" {
  type = string
  description = "Azure tenant Id"
}

variable "sp_object_id" {
  type = string
  description = "Service principal object id"
}

variable "aks_identity_id" {
  type = string
  description = "AKS azureKeyvaultSecretsProvider identity Id"
}

variable "kv_sku_name" {
  type = string
  description = "The Name of the SKU used for this Key Vault. Possible values are 'standard' and 'premium'"
  default = "standard"
}

variable "secrets" {
  type = map(string)
  description = "Map of secrets that will be maitained by terraform e.g {\"my-secret\" = \"my-secret-value\" }"
  sensitive = true
}