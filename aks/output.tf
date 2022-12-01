output "aks_id" {
  value = azurerm_kubernetes_cluster.mappia_aks.id
}

output "fqdn" {
  value = azurerm_public_ip.mappia_ip.fqdn
}

output "public_ip_address" {
  depends_on = [
    azurerm_role_assignment.aks_identity_ip_role_permission
  ]
  value = azurerm_public_ip.mappia_ip.ip_address
}

output "secret_provider_identity" {
  value = data.azurerm_kubernetes_cluster.mappia_aks.key_vault_secrets_provider[0].secret_identity[0]
  sensitive = true
}

output "kube_config_host" {
  value = data.azurerm_kubernetes_cluster.mappia_aks.kube_config.0.host
  sensitive = true
}

output "kube_config_client_cert" {
  value = data.azurerm_kubernetes_cluster.mappia_aks.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config_client_key" {
  value = data.azurerm_kubernetes_cluster.mappia_aks.kube_config.0.client_key
  sensitive = true
}

output "kube_config_ca_cert" {
  value = data.azurerm_kubernetes_cluster.mappia_aks.kube_config.0.cluster_ca_certificate
  sensitive = true
}
