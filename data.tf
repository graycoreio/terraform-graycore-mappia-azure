data "azurerm_resource_group" "mappia_rg" {
  name = var.resource_group_name
}

data "azurerm_kubernetes_cluster" "mappia_aks" {
  name                = azurerm_kubernetes_cluster.mappia_aks.name
  resource_group_name = azurerm_kubernetes_cluster.mappia_aks.resource_group_name
}
