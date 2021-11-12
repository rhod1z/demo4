# Create sql server - secondary.
resource "azurerm_sql_server" "secondary" {
  location                         = var.secondary_location
  resource_group_name              = var.resource_group_name
  name                             = var.sql_secondary_name
  administrator_login              = "azuresql"
  administrator_login_password     = "${data.azurerm_key_vault_secret.kv_sql_admin_password.value}"
  version                          = "12.0"
}

# Create sql server firewall rule.
# The feature 'Allow Azure services and resources to access this server' is enabled by setting start_ip_address and end_ip_address to 0.0.0.0.
resource "azurerm_sql_firewall_rule" "allowAzureServices" {
  resource_group_name              = var.resource_group_name
  name                             = "allowAzureServices"
  server_name                      = azurerm_sql_server.secondary.name
  start_ip_address                 = "0.0.0.0"
  end_ip_address                   = "0.0.0.0"
}

# Create sql server firewall rule - add home public ip for testing.
resource "azurerm_sql_firewall_rule" "allowHomeServices" {
  resource_group_name              = var.resource_group_name
  name                             = "allowHomeServices"
  server_name                      = azurerm_sql_server.secondary.name
  start_ip_address                 = "86.10.95.19"
  end_ip_address                   = "86.10.95.19"
}

# Create the failover group.
resource "azurerm_sql_failover_group" "sfg" {
  name                             = var.failover_group_name
  resource_group_name              = var.resource_group_name
  server_name                      = var.sql_server_primary
  databases                        = [var.sql_database_db_id]
  partner_servers {
    id = azurerm_sql_server.secondary.id
  }
  read_write_endpoint_failover_policy {
    mode                           = "Automatic"
    grace_minutes                  = 60
  }
}
