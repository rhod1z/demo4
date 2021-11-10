output "resource_group_name"           { value = azurerm_resource_group.rg.name }

output "plan_name"                     { value = module.az_webapp.plan_name }
output "webapp_name"                   { value = module.az_webapp.webapp_name }
output "default_site_hostname_prd"     { value = module.az_webapp.default_site_hostname_prd }
output "slot_name"                     { value = module.az_webapp.slot_name }
output "default_site_hostname_stg"     { value = module.az_webapp.default_site_hostname_stg }
output "custom_domain_verification_id" { value = module.az_webapp.custom_domain_verification_id }

output "kv_sql_admin_password" {
  value     = module.az_sqldb.kv_sql_admin_password
  sensitive = true
}
output "connection_string_primary" {
  value     = module.az_sqldb.connection_string_primary
  sensitive = true
}
