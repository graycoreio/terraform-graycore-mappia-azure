provider "azurerm" {
  features {}
  skip_provider_registration = "true"

  subscription_id = var.subscription_id
  client_id       = var.sp_id
  client_secret   = var.sp_secret
  tenant_id       = var.sp_tenant_id
}

provider "helm" {
  registry {
    url      = "oci://mappia.azurecr.io"
    password = var.helm_pwd
    username = var.helm_user
  }

  kubernetes {
    host = azurerm_kubernetes_cluster.mappia_aks.kube_config.0.host

    client_certificate     = base64decode(azurerm_kubernetes_cluster.mappia_aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.mappia_aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.mappia_aks.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.mappia_aks.kube_config.0.host

  client_certificate     = base64decode(azurerm_kubernetes_cluster.mappia_aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.mappia_aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.mappia_aks.kube_config.0.cluster_ca_certificate)
}
