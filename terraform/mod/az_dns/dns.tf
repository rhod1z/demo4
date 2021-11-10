######################
# CREATE DNS RECORDS #
######################
# ---------------------------------------------------------------- #
# ---------------------------------------------------------------- #
# Create cname record - prd
resource "azurerm_dns_cname_record" "dcr_prd" {
  name                = "prd"
  zone_name           = data.azurerm_dns_zone.dz.name
  resource_group_name = data.azurerm_dns_zone.dz.resource_group_name
  ttl                 = 300
  record              = var.default_site_hostname_prd
}
# Create txt record - prd
resource "azurerm_dns_txt_record" "dtr_prd" {
  name                = "asuid.prd"
  zone_name           = data.azurerm_dns_zone.dz.name
  resource_group_name = data.azurerm_dns_zone.dz.resource_group_name
  ttl                 = 300
  record {
    value = var.custom_domain_verification_id
  }
}
# ---------------------------------------------------------------- #
# ---------------------------------------------------------------- #
# Create cname record - stg
resource "azurerm_dns_cname_record" "dcr_stg" {
  name                = "stg"
  zone_name           = data.azurerm_dns_zone.dz.name
  resource_group_name = data.azurerm_dns_zone.dz.resource_group_name
  ttl                 = 300
  record              = var.default_site_hostname_stg
}
# Create txt record - stg
resource "azurerm_dns_txt_record" "dtr_stg" {
  name                = "asuid.stg"
  zone_name           = data.azurerm_dns_zone.dz.name
  resource_group_name = data.azurerm_dns_zone.dz.resource_group_name
  ttl                 = 300
  record {
    value = var.custom_domain_verification_id
  }
}
# ---------------------------------------------------------------- #
# ---------------------------------------------------------------- #
