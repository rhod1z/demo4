variable "default_site_hostname_prd" {}
variable "default_site_hostname_stg" {}
variable "custom_domain_verification_id" {}
variable "resource_group_name" {}
variable "custom_hostname_prd" {}
variable "custom_hostname_stg" {}
variable "app_service_name_prd" {}
variable "app_service_name_stg" {}
variable "location" {}

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
