# Databricks Account Management
# This file handles the Databricks Account configuration and AWS integration

# Get current AWS region
data "aws_region" "current" {}

# Use rootbucket for account storage configuration
locals {
  root_bucket_key = "rootbucket"
}

# Databricks Workspace (Account-level)
resource "databricks_mws_workspaces" "this" {
  provider = databricks.mws

  account_id               = var.databricks_account_id
  aws_region               = data.aws_region.current.name
  workspace_name           = var.account_name != null ? var.account_name : "${var.environment_name}-${var.name}"
  deployment_name          = "${var.environment_name}-${var.name}"
  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this[local.root_bucket_key].storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id
  pricing_tier             = var.pricing_tier

  # Additional workspace configuration
  is_no_public_ip_enabled = var.is_no_public_ip_enabled
  workspace_status        = "RUNNING"

  depends_on = [
    databricks_mws_credentials.this,
    databricks_mws_storage_configurations.this,
    databricks_mws_networks.this,
    time_sleep.wait_private_link
  ]

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-${var.name}"
    Environment = var.environment_name
    Service     = "databricks"
    ManagedBy   = "terraform"
  })
}
