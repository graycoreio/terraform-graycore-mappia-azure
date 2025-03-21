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

resource "azurerm_subnet" "aks_subnet" {
  count = var.create_aks_subnet ? 1 : 0

  address_prefixes     = var.aks_subnet_address_space
  name                 = var.aks_subnet_name
  resource_group_name  = data.azurerm_resource_group.mappia_rg.name
  virtual_network_name = azurerm_virtual_network.mappia_vn.name
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
      log_analytics_workspace_id      = var.oms_log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = true
    }
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = var.aks_network_profile.network_plugin
    service_cidr   = var.aks_network_profile.service_cidr
    dns_service_ip = var.aks_network_profile.dns_service_ip
  }

  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
  default_node_pool {
    name                        = var.default_node_pool.name
    vm_size                     = var.default_node_pool.vm_size
    auto_scaling_enabled        = true
    max_count                   = var.default_node_pool.max_count
    min_count                   = var.default_node_pool.min_count
    zones                       = var.default_node_pool.zones
    vnet_subnet_id              = var.create_aks_subnet ? azurerm_subnet.aks_subnet[0].id : null
    temporary_name_for_rotation = "temppool"

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }

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
  auto_scaling_enabled  = true
  max_count             = var.extra_node_pools[count.index].max_count
  min_count             = var.extra_node_pools[count.index].min_count
  zones                 = var.extra_node_pools[count.index].zones
  vnet_subnet_id        = var.create_aks_subnet ? azurerm_subnet.aks_subnet[0].id : null
  node_taints           = var.extra_node_pools[count.index].node_taint

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

resource "azurerm_role_definition" "mappia_networking" {
  name        = "Mappia AKS Ingress IP Address Reader"
  scope       = data.azurerm_resource_group.mappia_rg.id
  description = "This role allows the AKS Managed Identity to access and read IP addresses."

  permissions {
    actions = [
      "Microsoft.Network/publicIPAddresses/read",
    ]
  }

  assignable_scopes = [
    data.azurerm_resource_group.mappia_rg.id
  ]
}

resource "azurerm_role_definition" "mappia_networking_ip_join" {
  name        = "Mappia AKS Ingress IP Address Joiner"
  scope       = azurerm_public_ip.mappia_ip.id
  description = "This role allows the AKS Managed Identity to access and read IP addresses."

  permissions {
    actions = [
      "Microsoft.Network/publicIPAddresses/join/action"
    ]
  }

  assignable_scopes = [
    azurerm_public_ip.mappia_ip.id
  ]
}

resource "azurerm_role_assignment" "aks_identity_rg_ip_role_permission" {
  scope              = data.azurerm_resource_group.mappia_rg.id
  role_definition_id = azurerm_role_definition.mappia_networking.role_definition_resource_id
  principal_id       = azurerm_kubernetes_cluster.mappia_aks.identity[0].principal_id
  depends_on = [
    azurerm_role_definition.mappia_networking
  ]
}

resource "azurerm_role_assignment" "aks_identity_ip_role_permission" {
  scope              = azurerm_public_ip.mappia_ip.id
  role_definition_id = azurerm_role_definition.mappia_networking_ip_join.role_definition_resource_id
  principal_id       = azurerm_kubernetes_cluster.mappia_aks.identity[0].principal_id
  depends_on = [
    azurerm_role_definition.mappia_networking_ip_join
  ]
}

resource "kubernetes_storage_class" "mappia_writable" {
  depends_on = [
    azurerm_kubernetes_cluster.mappia_aks
  ]
  metadata {
    name = "azurefile-csi-web-writable"
  }
  storage_provisioner = "file.csi.azure.com"
  volume_binding_mode = "Immediate"
  mount_options = [
    "dir_mode=0777",
    "file_mode=0777",
    "gid=82",
    "uid=82",
    "mfsymlinks",
    "cache=strict",
    "nosharesock",
  ]
  parameters = {
    skuName = "Standard_LRS"
  }
}

resource "kubernetes_storage_class" "mappia_writable_premium" {
  depends_on = [
    azurerm_kubernetes_cluster.mappia_aks
  ]

  metadata {
    name = "azurefile-premium-csi-web-writable"
  }
  storage_provisioner = "file.csi.azure.com"
  volume_binding_mode = "Immediate"
  mount_options = [
    "dir_mode=0777",
    "file_mode=0777",
    "gid=82",
    "uid=82",
    "mfsymlinks",
    "cache=strict",
    "nosharesock",
  ]
  parameters = {
    skuName = "Premium_LRS"
  }
}

resource "kubernetes_storage_class" "mappia_writable_premium_loose" {
  depends_on = [
    azurerm_kubernetes_cluster.mappia_aks
  ]

  metadata {
    name = "azurefile-premium-csi-web-writable-loose"
  }
  storage_provisioner = "file.csi.azure.com"
  volume_binding_mode = "Immediate"
  mount_options = [
    "dir_mode=0777",
    "file_mode=0777",
    "gid=82",
    "uid=82",
    "mfsymlinks",
    "cache=loose",
    "nosharesock",
  ]
  parameters = {
    skuName = "Premium_LRS"
  }
}

resource "random_pet" "domain_name" {
  count = var.domain_name_label == "" ? 1 : 0
}

locals {
  random_domain_name = one(random_pet.domain_name[*].id)
}
