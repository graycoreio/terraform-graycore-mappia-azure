resource "random_pet" "aks_name" {
  count = var.aks_name == "" ? 1 : 0
}

resource "random_pet" "dns_prefix" {
  count = var.dns_prefix == "" ? 1 : 0
}

locals {
  random_aks_name   = one(random_pet.aks_name[*].id)
  random_dns_prefix = one(random_pet.dns_prefix[*].id)
}

resource "azurerm_kubernetes_cluster" "mappia_aks" {
  name                = coalesce(var.aks_name, local.random_aks_name)
  location            = local.location
  resource_group_name = var.resource_group_name
  dns_prefix          = coalesce(var.dns_prefix, local.random_dns_prefix)
  kubernetes_version  = var.kubernetes_version
  oidc_issuer_enabled = true

  dynamic "oms_agent" {
    for_each = var.oms_log_analytics_workspace_id != "" ? ["this"] : []
    content {
      log_analytics_workspace_id = var.oms_log_analytics_workspace_id
    }
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
  default_node_pool {
    name                = var.default_node_pool.name
    vm_size             = var.default_node_pool.vm_size
    enable_auto_scaling = true
    max_count           = var.default_node_pool.max_count
    min_count           = var.default_node_pool.min_count
    zones               = var.default_node_pool.zones

    dynamic "linux_os_config" {
      for_each = var.default_node_pool.set_max_map_count ? ["this"] : []
      content {
        sysctl_config {
          # opensearch required configuration
          vm_max_map_count = 262144
        }
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
  zones                 = var.extra_node_pools[count.index].zones

  dynamic "linux_os_config" {
    for_each = var.extra_node_pools[count.index].set_max_map_count ? ["this"] : []
    content {
      sysctl_config {
        # opensearch required configuration
        vm_max_map_count = 262144
      }
    }
  }
}

resource "azurerm_public_ip" "mappia_ip" {
  name                = var.public_ip_name
  location            = local.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  ip_version          = "IPv4"
  sku                 = "Standard"
  domain_name_label   = coalesce(var.domain_name_label, local.random_domain_name)
  zones               = var.public_ip_zones
}


resource "azurerm_role_assignment" "aks_identity_ip_role_permission" {
  scope                = azurerm_public_ip.mappia_ip.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.mappia_aks.identity[0].principal_id
}

resource "random_pet" "domain_name" {
  count = var.domain_name_label == "" ? 1 : 0
}

locals {
  random_domain_name = one(random_pet.domain_name[*].id)
}
