output "cname_fqdn_prd" { value = azurerm_dns_cname_record.dcr_prd.fqdn }
output "txt_fqdn_prd"   { value = azurerm_dns_txt_record.dtr_prd.fqdn }
