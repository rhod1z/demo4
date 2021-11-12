output "resource_group_name"           { value = azurerm_resource_group.rg.name }

output "plan_name"                     { value = module.az_webapp.plan_name }
output "webapp_name"                   { value = module.az_webapp.webapp_name }
output "default_site_hostname_prd"     { value = module.az_webapp.default_site_hostname_prd }
output "slot_name"                     { value = module.az_webapp.slot_name }
output "default_site_hostname_stg"     { value = module.az_webapp.default_site_hostname_stg }
output "custom_domain_verification_id" { value = module.az_webapp.custom_domain_verification_id }

output "sql_server_primary"            { value = module.az_sqldb.sql_server_primary }
output "sql_database_db_id"            { value = module.az_sqldb.sql_database_db_id }
output "kv_sql_admin_password" {
  value     = module.az_sqldb.kv_sql_admin_password
  sensitive = true
}
output "connection_string_primary" {
  value     = module.az_sqldb.connection_string_primary
  sensitive = true
}

output "connection_string_secondary" {
  value     = module.az_sqldb_failover.connection_string_secondary
  sensitive = true
}
output "connection_string_failover" {
  value     = module.az_sqldb_failover.connection_string_failover
  sensitive = true
}

output "cname_fqdn_prd" { value = module.az_dns.cname_fqdn_prd }
output "txt_fqdn_prd"   { value = module.az_dns.txt_fqdn_prd }
