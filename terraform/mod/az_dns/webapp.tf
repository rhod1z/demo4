####################
# CONFIGURE WEBAPP #
####################
# ---------------------------------------------------------------- #
# COMMON / SHARED -------------------------------------------------#
# ---------------------------------------------------------------- #
# Set perms for 'WebApp Service Resource Principal' to retrieve rhod3rz.com tls cert.
resource "azurerm_key_vault_access_policy" "kvap" {
  key_vault_id = data.azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_key_vault.kv.tenant_id
  object_id    = data.azuread_service_principal.microsoftwebapp.id
  secret_permissions = [
    "get"
  ]
  certificate_permissions = [
    "get"
  ]
  lifecycle {
    ignore_changes = all
  }
}
# Uploads rhod3rz.com tls cert to webapp; but doesn't bind it.
resource "azurerm_app_service_certificate" "asc" {
  name                = "rhod3rz-com"
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_secret_id = data.azurerm_key_vault_certificate.kvc.id
  lifecycle {
    ignore_changes = all
  }
}
# ---------------------------------------------------------------- #
# PRD -------------------------------------------------------------#
# ---------------------------------------------------------------- #
# Sleep to allow dns record creation before creating custom hostname binding.
resource "time_sleep" "ts_prd" {
  depends_on      = [azurerm_dns_cname_record.dcr_prd,azurerm_dns_txt_record.dtr_prd]
  create_duration = "30s"
}
# Create custom hostname binding.
resource "azurerm_app_service_custom_hostname_binding" "aschb_prd" {
  depends_on           = [azurerm_app_service_certificate.asc,time_sleep.ts_prd]
  resource_group_name  = var.resource_group_name
  hostname             = var.custom_hostname_prd
  app_service_name     = var.app_service_name_prd
  ssl_state            = "SniEnabled"
  thumbprint           = data.azurerm_key_vault_certificate.kvc.thumbprint
  lifecycle {
    ignore_changes = all
  }
}
# ---------------------------------------------------------------- #
# STG -------------------------------------------------------------#
# ---------------------------------------------------------------- #
# Sleep to allow dns record creation before creating custom hostname binding.
resource "time_sleep" "ts_stg" {
  depends_on      = [azurerm_dns_cname_record.dcr_stg,azurerm_dns_txt_record.dtr_stg]
  create_duration = "30s"
}
# Create custom hostname binding.
# NOTE: Slot custom hostname binding isn't supported in terraform so an ARM template workaround is required.
resource "azurerm_template_deployment" "td" {
  depends_on           = [azurerm_app_service_certificate.asc,time_sleep.ts_stg]
  resource_group_name  = var.resource_group_name
  name                 = "stg_custom_hostname"
  template_body        = file("../../mod/az_dns/app-service-slot-custom-hostname.json")
  parameters = {
    "hostname"         = var.custom_hostname_stg
    "app_service_name" = var.app_service_name_prd
    "name_of_slot"     = "stg"
    "location"         = var.location
    "thumbprint"       = data.azurerm_key_vault_certificate.kvc.thumbprint
  }
  deployment_mode      = "Incremental"
}
