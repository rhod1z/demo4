# Create log analytics workspace.
resource "azurerm_log_analytics_workspace" "law" {
  location                    = var.location
  resource_group_name         = var.resource_group_name
  name                        = var.log_analytics_workspace_name
  sku                         = "PerGB2018"
}

# Create linux app service plan.
resource "azurerm_app_service_plan" "asp" {
  location             = var.location
  resource_group_name  = var.resource_group_name
  name                 = var.plan_name
  kind                 = "Linux"
  reserved             = true       /* Must be set to 'true' for linux and 'false' for windows */
  sku {
      # tier = "Basic"
      # size = "B1"
      tier = "PremiumV2"            /* This is the smallest plan with 'staging slots' */
      size = "P1v2"                 /* This is the smallest plan with 'staging slots' */
  }
}

# Create web app / app service.
resource "azurerm_app_service" "as" {
  location             = var.location
  resource_group_name  = var.resource_group_name
  name                 = var.webapp_name
  app_service_plan_id  = azurerm_app_service_plan.asp.id

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = var.acr_login_server
    DOCKER_REGISTRY_SERVER_USERNAME     = var.acr_admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = "${data.azurerm_key_vault_secret.kv_acrdlnteudemoapps210713.value}"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = var.connection_string
  }

  identity {
    type = "SystemAssigned"
  }

  # Redirects http requests to https.
  https_only = true

  # Enable logs. Download logs from https://<app-name>.scm.azurewebsites.net/api/logs/docker/zip.
  logs {
    http_logs {
      file_system {
        retention_in_days = "5"
        retention_in_mb = "25"
      }
    }
  }

  site_config {
    always_on        = "true"
    linux_fx_version = "DOCKER|mcr.microsoft.com/appsvc/staticsite:latest"
  }

  # Ignore docker image changes as ADO pipeline will manage that.
  lifecycle {
    ignore_changes = [
      site_config,
      app_settings
    ]
  }
}

# Configure web app diagnostic settings to send logs to log analytics.
resource "azurerm_monitor_diagnostic_setting" "mds" {
  name                       = "Log-Analytics"
  target_resource_id         = azurerm_app_service.as.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  log    { category = "AppServiceHTTPLogs" }
  log    { category = "AppServiceConsoleLogs" }
  log    { category = "AppServiceAppLogs" }
  log    { category = "AppServicePlatformLogs" }
  metric { category = "AllMetrics" }
}

# Configure web app scale out settings.
resource "azurerm_monitor_autoscale_setting" "mas" {
  location             = var.location
  resource_group_name  = var.resource_group_name
  name                = "myAutoscaleSetting"
  target_resource_id  = azurerm_app_service_plan.asp.id
  profile {
    name = "default"
    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.asp.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 90
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.asp.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 10
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}

resource "azurerm_app_service_slot" "ass" {
  location             = var.location
  resource_group_name  = var.resource_group_name
  name                = "stg"
  app_service_name    = azurerm_app_service.as.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = var.acr_login_server
    DOCKER_REGISTRY_SERVER_USERNAME     = var.acr_admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = "${data.azurerm_key_vault_secret.kv_acrdlnteudemoapps210713.value}"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
  }

  site_config {
    always_on        = "true"
    linux_fx_version = "DOCKER|mcr.microsoft.com/appsvc/staticsite:latest"
    # Restrict access to only via the AGW; not direct to web app.
    # ip_restriction {
    #   ip_address = "${var.public_ip_ip_address}/32"
    #   priority   = "300"
    #   action     = "Allow"
    # }
  }

  identity {
    type = "SystemAssigned"
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = var.connection_string
  }

  # Ignore docker image changes as ADO pipeline will manage that.
  lifecycle {
    ignore_changes = [
      site_config,
      app_settings
    ]
  }
}
