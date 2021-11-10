# Get azure dns zone.
data "azurerm_dns_zone" "dz" {
  name                = "rhod3rz.com"
  resource_group_name = "rg-core-01"
}

# If using key_vault_secret_id, the WebApp Service Resource Principal ID abfa0a7c-a6b6-4736-8310-5855508787cd
# must have 'Secret -> get' and 'Certificate -> get' permissions on the Key Vault containing the certificate.
# NOTE: Must add 'sp-terraform-deployment' to Azure AD > Roles & Administrators > Directory Readers.
data "azuread_service_principal" "microsoftwebapp" {
  application_id = "abfa0a7c-a6b6-4736-8310-5855508787cd"
}

# Get key vault.
data "azurerm_key_vault" "kv" {
  name                = "kv-core-210713"
  resource_group_name = "rg-core-01"
}

# Get tls certificate.
data "azurerm_key_vault_certificate" "kvc" {
  name         = "rhod3rz-com"
  key_vault_id = data.azurerm_key_vault.kv.id
}