output "acr_admin_pwd" {
  value     = var.acr_enabled && var.acr_admin_enabled ? azurerm_container_registry.mappia_acr[0].admin_password : "[INFO]: Container registry admin disabled"
  sensitive = true
}

output "acr_admin_user" {
  value     = var.acr_enabled && var.acr_admin_enabled ? azurerm_container_registry.mappia_acr[0].admin_username : "[INFO]: Container registry admin disabled"
  sensitive = true
}

output "acr_name" {
  value = var.acr_enabled ? azurerm_container_registry.mappia_acr[0].name : "[INFO]: Container registry disabled"
}

output "ip_address" {
  value = azurerm_public_ip.mappia_ip.ip_address
}

output "full_qualified_domain_name" {
  value = azurerm_public_ip.mappia_ip.fqdn
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.mappia_aks.name
}

output "kube_config_host" {
  value     = data.azurerm_kubernetes_cluster.mappia_aks.kube_config.0.host
  sensitive = true
}

output "kube_config_client_cert" {
  value     = data.azurerm_kubernetes_cluster.mappia_aks.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config_client_key" {
  value     = data.azurerm_kubernetes_cluster.mappia_aks.kube_config.0.client_key
  sensitive = true
}

output "kube_config_ca_cert" {
  value     = data.azurerm_kubernetes_cluster.mappia_aks.kube_config.0.cluster_ca_certificate
  sensitive = true
}

output "kube_config_raw" {
  value     = data.azurerm_kubernetes_cluster.mappia_aks.kube_config_raw
  sensitive = true
}