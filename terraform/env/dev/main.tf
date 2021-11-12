locals {
  location                        = "northeurope"
  loc                             = "nteu"
  env                             = "dev"
  app                             = "myhealth"                                              /* The app identifier */
  uniq                            = "211019-1100"                                           /**** UPDATE HERE - VERSION ****/
  date                            = "211019"                                                /**** UPDATE HERE - VERSION ****/
}

# Create resource group.
resource "azurerm_resource_group" "rg" {
  location                        = local.location
  name                            = "rg-${local.env}-${local.app}-${local.uniq}"
  tags                            = local.common_tags
}

# Create webapp.
module "az_webapp" {
  source                          = "../../mod/az_webapp"                                   /* The path to the module */
  depends_on                      = [module.az_sqldb]                                       /* Wait for dependencies */
  location                        = local.location                                          /* The location */
  resource_group_name             = azurerm_resource_group.rg.name                          /* The resource group */
  log_analytics_workspace_name    = "log-${local.env}-${local.app}-${local.uniq}"           /* The log analytics workspace name; must be globally unique across azure */
  plan_name                       = "${local.env}-pln-${local.app}-${local.uniq}"           /* The plan name */
  webapp_name                     = "${local.env}-app-${local.app}-${local.uniq}"           /* The webapp name */
  acr_login_server                = "https://acrdlnteudemoapps210713.azurecr.io"            /* The acr server */
  acr_admin_username              = "acrdlnteudemoapps210713"                               /* The acr username */
  connection_string               = module.az_sqldb.connection_string_primary               /* MODULE IMPORT - db connection string */
}

# Create azure sql db - primary.
module "az_sqldb" {
  source                          = "../../mod/az_sqldb"                                    /* The path to the module */
  location                        = local.location                                          /* The location */
  resource_group_name             = azurerm_resource_group.rg.name                          /* The resource group */
  primary_location                = "northeurope"                                           /* SQL primary location */
  sql_primary_name                = "${local.env}-sql-${local.app}-primary"                 /* SQL primary name */
}
