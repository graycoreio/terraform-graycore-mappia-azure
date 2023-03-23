# Generate random value for the name
resource "random_string" "server_name" {
  length  = 8
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_virtual_network" "mappia_vn" {
  name                = var.virtual_network_name == "" ? "vnet-${random_string.server_name.result}" : var.virtual_network_name
  location            = local.location
  resource_group_name = data.azurerm_resource_group.mappia_rg.name
  address_space       = var.address_space
}
  