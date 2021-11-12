variable "location" {}
variable "resource_group_name" {}
variable "secondary_location" {}
variable "sql_secondary_name" {}
variable "failover_group_name" {}
variable "sql_server_primary" {}
variable "sql_database_db_id" {}

# Define the common tags for all resources.
locals {
  common_tags = {
    Owner       = "rhod3rz"
    Application = "MyHealth"
  }
}

# Create a timestamp variable to use if required.
locals {
  timestamp           = "${timestamp()}"
  timestamp_sanitized = "${replace("${local.timestamp}", "/[-|T|Z|:]/", "")}"
  timestamp_10chars   = "${substr("${local.timestamp_sanitized}", "2", "10")}"
}
