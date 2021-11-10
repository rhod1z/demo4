output "plan_name"                     { value = azurerm_app_service_plan.asp.name }

output "webapp_name"                   { value = azurerm_app_service.as.name }
output "default_site_hostname_prd"     { value = azurerm_app_service.as.default_site_hostname }
output "slot_name"                     { value = azurerm_app_service_slot.ass.name }
output "default_site_hostname_stg"     { value = azurerm_app_service_slot.ass.default_site_hostname }
output "custom_domain_verification_id" { value = azurerm_app_service.as.custom_domain_verification_id }
