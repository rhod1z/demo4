variable "location" {}
variable "resource_group_name" {}
variable "log_analytics_workspace_name" {}
variable "plan_name" {}
variable "webapp_name" {}
variable "acr_login_server" {}
variable "acr_admin_username" {}
variable "connection_string" {}

# Define the common tags for all resources.
locals {
  common_tags = {
    Owner       = "rhod3rz"
    Application = "myhealth"
  }
}

# Create a timestamp variable to use if required.
locals {
  timestamp           = "${timestamp()}"
  timestamp_sanitized = "${replace("${local.timestamp}", "/[-|T|Z|:]/", "")}"
  timestamp_10chars   = "${substr("${local.timestamp_sanitized}", "2", "10")}"
}
