variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
  default     = "mappia"
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

variable "subscription_id" {
  type        = string
  description = "Azure subscription id"
}

variable "sp_tenant_id" {
  type        = string
  description = "Service principal tenant id"
}

variable "helm_release_name" {
  type        = string
  description = "Mappia chart release name"
  default     = "mappia"
}

variable "secrets" {
  type        = map(string)
  description = "Map of secrets that will be maitained by terraform e.g {\"my-secret\" = \"my-secret-value\" }"
  sensitive   = true
  default = {}
}