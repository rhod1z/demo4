# Create sql server - primary.
resource "azurerm_sql_server" "primary" {
  location                         = var.primary_location
  resource_group_name              = var.resource_group_name
  name                             = var.sql_primary_name
  administrator_login              = "azuresql"
  administrator_login_password     = "${data.azurerm_key_vault_secret.kv_sql_admin_password.value}"
  version                          = "12.0"
}

# Create sql server firewall rule.
# The feature 'Allow Azure services and resources to access this server' is enabled by setting start_ip_address and end_ip_address to 0.0.0.0.
resource "azurerm_sql_firewall_rule" "allowAzureServices" {
  resource_group_name              = var.resource_group_name
  name                             = "allowAzureServices"
  server_name                      = azurerm_sql_server.primary.name
  start_ip_address                 = "0.0.0.0"
  end_ip_address                   = "0.0.0.0"
}

# Create sql server firewall rule - add home public ip for testing.
resource "azurerm_sql_firewall_rule" "allowHomeServices" {
  resource_group_name              = var.resource_group_name
  name                             = "allowHomeServices"
  server_name                      = azurerm_sql_server.primary.name
  start_ip_address                 = "86.10.95.19"
  end_ip_address                   = "86.10.95.19"
}

# Create a database & import bacpac (schema & data).
# Note: You cannot import once the database already exists; only on creation.
resource "azurerm_sql_database" "db" {
  depends_on                       = [ azurerm_sql_firewall_rule.allowAzureServices ]
  location                         = var.location
  resource_group_name              = var.resource_group_name
  name                             = "mhcdb"
  server_name                      = azurerm_sql_server.primary.name
  create_mode                      = "Default"
  collation                        = "SQL_LATIN1_GENERAL_CP1_CI_AS"
  requested_service_objective_name = "S0"
  import {
    storage_uri                    = "https://sadlother210713.blob.core.windows.net/myhealth/myhealthclinic.bacpac"
    storage_key                    = "${data.azurerm_key_vault_secret.kv_sadlother_access_key.value}"
    storage_key_type               = "StorageAccessKey"
    administrator_login            = "azuresql"
    administrator_login_password   = "${data.azurerm_key_vault_secret.kv_sql_admin_password.value}"
    authentication_type            = "SQL"
  }
}
