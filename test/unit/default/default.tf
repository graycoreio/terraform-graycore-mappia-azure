# Main
module "my-terraform-project" {
  source = "../../.."

  resource_group_name = var.mappia_resource_group
  location            = "eastus2"
  sp_id               = var.mappia_sp_id
  sp_object_id        = var.mappia_sp_object_id
  sp_secret           = var.mappia_sp_password
  subscription_id     = var.mappia_subscription_id
  sp_tenant_id        = var.mappia_sp_tenant_id
  helm_user           = var.mappia_helm_user
  helm_pwd            = var.mappia_helm_pwd
}

# Variables
variable "mappia_resource_group" {
  type        = string
  description = "Resource group"
}

variable "mappia_sp_id" {
  type        = string
  description = "Service principal client Id"
}

variable "mappia_sp_object_id" {
  type        = string
  description = "Service principal object Id"
}

variable "mappia_sp_password" {
  type        = string
  description = "Service principal client secret"
}

variable "mappia_subscription_id" {
  type        = string
  description = "Azure subscription id"
}

variable "mappia_sp_tenant_id" {
  type        = string
  description = "Service principal tenant id"
}

variable "mappia_helm_user" {
  type        = string
  description = "Helm mappia user name provided by graycore"
}

variable "mappia_helm_pwd" {
  type        = string
  description = "Helm mappia password (token) provided by graycore"
}

# Outputs
output "acr_admin_pwd" {
  value     = module.my-terraform-project.acr_admin_pwd
  sensitive = true
}

output "acr_admin_user" {
  value     = module.my-terraform-project.acr_admin_user
  sensitive = true
}

output "acr_name" {
  value = module.my-terraform-project.acr_name
}

output "ip_address" {
  value = module.my-terraform-project.ip_address
}

output "full_qualified_domain_name" {
  value = module.my-terraform-project.full_qualified_domain_name
}

output "aks_name" {
  value = module.my-terraform-project.aks_name
}

output "kube_config_raw" {
  value     = module.my-terraform-project.kube_config_raw
  sensitive = true
}

