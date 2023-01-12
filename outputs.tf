output "ip_address" {
  value = azurerm_public_ip.mappia_ip.ip_address
}

output "full_qualified_domain_name" {
  value = azurerm_public_ip.mappia_ip.fqdn
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
