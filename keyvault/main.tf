resource "random_pet" "kv_name" {
  prefix = "mappia"
}

resource "random_password" "mage_encryption_key" {
  length           = 32
  special          = false
}

resource "random_password" "shared_cache_pwd" {
  length           = 16
  special          = false
}

# Key-Vault
resource "azurerm_key_vault" "mappia-kv" {
  name                = random_pet.kv_name.id
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku_name            = var.kv_sku_name
  tenant_id           = var.tenant_id

  enabled_for_template_deployment = true
}

resource "azurerm_key_vault_access_policy" "sp-access-policy" {
  object_id    = var.sp_object_id
  key_vault_id = azurerm_key_vault.mappia-kv.id
  tenant_id    = var.tenant_id

  secret_permissions = ["Get", "Set", "Delete", "Purge"]
}

resource "azurerm_key_vault_access_policy" "aks-access-policy" {
  object_id    = var.aks_identity_id
  key_vault_id = azurerm_key_vault.mappia-kv.id
  tenant_id    = var.tenant_id

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
  value        = random_password.mage_encryption_key.result

  depends_on = [
    azurerm_key_vault_access_policy.sp-access-policy
  ]
}

resource "azurerm_key_vault_secret" "magento_shared_cache_pwd" {
  key_vault_id = azurerm_key_vault.mappia-kv.id
  name         = "magento-shared-cache-pwd"
  value        = random_password.shared_cache_pwd.result

  depends_on = [
    azurerm_key_vault_access_policy.sp-access-policy
  ]
}