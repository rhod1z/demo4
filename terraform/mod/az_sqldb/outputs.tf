output "sql_server_primary"        { value = azurerm_sql_server.primary.name }
output "sql_database_db_id"        { value = azurerm_sql_database.db.id }

output "kv_sql_admin_password"     { value = data.azurerm_key_vault_secret.kv_sql_admin_password.value }

output "connection_string_primary" { value = "Server=tcp:${azurerm_sql_server.primary.name}.database.windows.net,1433;Initial Catalog=mhcdb;Persist Security Info=False;User ID=azuresql;Password=${data.azurerm_key_vault_secret.kv_sql_admin_password.value};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" }
