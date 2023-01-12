resource "random_pet" "kv_name" {
  count  = var.kv_name == "" ? 1 : 0
  prefix = "mappia"
}

resource "random_password" "mage_encryption_key" {
  count   = var.encryption_key == "" ? 1 : 0
  length  = 32
  special = false
}

resource "random_password" "shared_cache_pwd" {
  count   = var.shared_cache_pwd == "" ? 1 : 0
  length  = 16
  special = false
}

# Key-Vault
resource "azurerm_key_vault" "mappia-kv" {
  name                = coalesce(var.kv_name, local.random_kv_name)
  location            = local.location
  resource_group_name = var.resource_group_name
  sku_name            = var.kv_sku_name
  tenant_id           = var.sp_tenant_id

  enabled_for_template_deployment = true
}

resource "azurerm_key_vault_access_policy" "sp-access-policy" {
  object_id    = var.sp_object_id
  key_vault_id = azurerm_key_vault.mappia-kv.id
  tenant_id    = var.sp_tenant_id

  secret_permissions = ["Get", "Set", "Delete", "Purge"]
}

resource "azurerm_key_vault_access_policy" "aks-access-policy" {
  object_id    = azurerm_kubernetes_cluster.mappia_aks.key_vault_secrets_provider[0].secret_identity[0].object_id
  key_vault_id = azurerm_key_vault.mappia-kv.id
  tenant_id    = var.sp_tenant_id

  secret_permissions = ["Get"]
}

resource "azurerm_key_vault_secret" "mappia-secrets" {
  count = length(var.secrets)

  key_vault_id = azurerm_key_vault.mappia-kv.id
  name         = keys(var.secrets)[count.index]
  value        = values(var.secrets)[count.index]

  depends_on = [
    azurerm_key_vault_access_policy.sp-access-policy
  ]
}

resource "azurerm_key_vault_secret" "magento_encryption_key" {
  key_vault_id = azurerm_key_vault.mappia-kv.id
  name         = "magento-encryption-key"
  value        = coalesce(var.encryption_key, local.random_encryption_key)

  depends_on = [
    azurerm_key_vault_access_policy.sp-access-policy
  ]
}

resource "azurerm_key_vault_secret" "magento_shared_cache_pwd" {
  key_vault_id = azurerm_key_vault.mappia-kv.id
  name         = "magento-shared-cache-pwd"
  value        = coalesce(var.shared_cache_pwd, local.random_shared_cache_pwd)

  depends_on = [
    azurerm_key_vault_access_policy.sp-access-policy
  ]
}

locals {
  random_encryption_key   = one(random_password.mage_encryption_key[*].result)
  random_shared_cache_pwd = one(random_password.shared_cache_pwd[*].result)
  random_kv_name          = one(random_pet.kv_name[*].id)
}