locals {
  location                        = "northeurope"
  loc                             = "nteu"
  env                             = "prd"
  app                             = "myhealth"                                              /* The app identifier */
  uniq                            = "211018-1500"                                           /**** UPDATE HERE - VERSION ****/
  date                            = "211018"                                                /**** UPDATE HERE - VERSION ****/
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
  depends_on                      = [module.az_sqldb,module.az_sqldb_failover]              /* Wait for dependencies */
  location                        = local.location                                          /* The location */
  resource_group_name             = azurerm_resource_group.rg.name                          /* The resource group */
  log_analytics_workspace_name    = "log-${local.env}-${local.app}-${local.uniq}"           /* The log analytics workspace name; must be globally unique across azure */
  plan_name                       = "${local.env}-pln-${local.app}-${local.uniq}"           /* The plan name */
  webapp_name                     = "${local.env}-app-${local.app}-${local.uniq}"           /* The webapp name */
  acr_login_server                = "https://acrdlnteudemoapps210713.azurecr.io"            /* The acr server */
  acr_admin_username              = "acrdlnteudemoapps210713"                               /* The acr username */
  connection_string               = module.az_sqldb_failover.connection_string_failover     /* MODULE IMPORT - db connection string */
}

# Create azure sql db - primary.
module "az_sqldb" {
  source                          = "../../mod/az_sqldb"                                    /* The path to the module */
  location                        = local.location                                          /* The location */
  resource_group_name             = azurerm_resource_group.rg.name                          /* The resource group */
  primary_location                = "northeurope"                                           /* SQL primary location */
  sql_primary_name                = "${local.env}-sql-${local.app}-primary"                 /* SQL primary name */
}

# Create azure sql db - secondary.
module "az_sqldb_failover" {
  source                          = "../../mod/az_sqldb_failover"                           /* The path to the module */
  depends_on                      = [module.az_sqldb]                                       /* Wait for dependencies */
  location                        = local.location                                          /* The location */
  resource_group_name             = azurerm_resource_group.rg.name                          /* The resource group */
  secondary_location              = "westeurope"                                            /* SQL secondary location for failover group */
  sql_secondary_name              = "${local.env}-sql-${local.app}-secondary"               /* SQL secondary name */
  failover_group_name             = "nteu2wteu"                                             /* The name of the failover group; in this case northeurope to westeurope */
  sql_server_primary              = module.az_sqldb.sql_server_primary                      /* SQL primary name - required for failover config */
  sql_database_db_id              = module.az_sqldb.sql_database_db_id                      /* Database id - required for failover config */
}

# Create dns records.
module "az_dns" {
  source                          = "../../mod/az_dns"                                      /* The path to the module */
  depends_on                      = [module.az_webapp]                                      /* Wait for dependencies */
  default_site_hostname_prd       = module.az_webapp.default_site_hostname_prd              /* Web app fqdn - prd */
  default_site_hostname_stg       = module.az_webapp.default_site_hostname_stg              /* Web app fqdn - stg */
  custom_domain_verification_id   = module.az_webapp.custom_domain_verification_id          /* Domain verification id */
  resource_group_name             = azurerm_resource_group.rg.name                          /* The resource group */
  custom_hostname_prd             = "prd.rhod3rz.com"                                       /* Prd custom hostname binding */
  custom_hostname_stg             = "stg.rhod3rz.com"                                       /* Stg custom hostname binding */
  app_service_name_prd            = module.az_webapp.webapp_name                            /* Prd web app name */
  app_service_name_stg            = module.az_webapp.slot_name                              /* Stg web app name */
  location                        = local.location                                          /* The location */
}
