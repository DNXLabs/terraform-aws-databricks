# External ID Management
# This file handles external ID generation for Databricks IAM role

# Generate external ID once and store in state
resource "random_string" "databricks_external_id" {
  length  = 32
  special = false
  upper   = true

  keepers = {
    # Keep the same external ID based on account name and environment
    account_name = "${var.environment_name}-${var.name}"
  }
}

# External ID from state
locals {
  external_id = random_string.databricks_external_id.result
}



