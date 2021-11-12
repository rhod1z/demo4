data "azurerm_key_vault" "key_vault" {
  name                = "kv-core-210713"
  resource_group_name = "rg-core-01"
}

# Get sql admin password.
data "azurerm_key_vault_secret" "kv_sql_admin_password" {
  name         = "KV-SQL-ADMIN-PASSWORD"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

# Get storage account access key for bacpac file.
data "azurerm_key_vault_secret" "kv_sadlother_access_key" {
  name         = "KV-SADLOTHER-ACCESS-KEY"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}
