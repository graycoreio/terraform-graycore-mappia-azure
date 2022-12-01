resource "azurerm_kubernetes_cluster" "mappia_aks" {
  name                = var.name
  location            = var.rg_location
  resource_group_name = var.rg_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  oidc_issuer_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
  default_node_pool {
    name                = "defpool"
    vm_size             = var.default_node_pool.vm_size
    enable_auto_scaling = true
    max_count           = var.default_node_pool.max_count
    min_count           = var.default_node_pool.min_count

    linux_os_config {
      sysctl_config {
        # opensearch required configuration
        vm_max_map_count = 262144
      }
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "mappia_aks_extra_nodes" {
  count = length(var.extra_node_pools)

  name                  = var.extra_node_pools[count.index].name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.mappia_aks.id
  vm_size               = var.extra_node_pools[count.index].vm_size
  enable_auto_scaling   = true
  max_count             = var.extra_node_pools[count.index].max_count
  min_count             = var.extra_node_pools[count.index].min_count

  linux_os_config {
    sysctl_config {
      # opensearch required configuration
      vm_max_map_count = 262144
    }
  }
}

resource "azurerm_public_ip" "mappia_ip" {
  name                = "mappia-public-ip"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  ip_version          = "IPv4"
  sku                 = "Standard"
  domain_name_label   = "mappia"
}


resource "azurerm_role_assignment" "aks_identity_ip_role_permission" {
  scope                = azurerm_public_ip.mappia_ip.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.mappia_aks.identity[0].principal_id
}