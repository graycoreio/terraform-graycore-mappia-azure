resource "random_pet" "acr_name" {
  count     = var.acr_enabled && var.acr_name == "" ? 1 : 0
  separator = ""
}

locals {
  random_acr_name = one(random_pet.acr_name[*].id)
}

resource "azurerm_container_registry" "mappia_acr" {
  count = var.acr_enabled ? 1 : 0

  name                = coalesce(var.acr_name, local.random_acr_name)
  resource_group_name = data.azurerm_resource_group.mappia_rg.name
  location            = local.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
}

resource "azurerm_role_assignment" "mappia_acr_to_aks" {
  count = var.acr_enabled ? 1 : 0

  principal_id                     = azurerm_kubernetes_cluster.mappia_aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.mappia_acr[0].id
  skip_service_principal_aad_check = true
}
