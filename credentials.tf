# Databricks MWS Credentials
# This file handles the Databricks credentials configuration for AWS integration

# Official Databricks data sources for IAM policies
data "databricks_aws_assume_role_policy" "this" {
  external_id = local.external_id
}

data "databricks_aws_crossaccount_policy" "this" {
}

# IAM Role for Databricks cross-account access
resource "aws_iam_role" "databricks_account" {
  name               = "${var.environment_name}-${var.name}-databricks-role"
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-${var.name}-databricks-role"
    Environment = var.environment_name
    Service     = "databricks"
    ManagedBy   = "terraform"
  })
}

# IAM Policy for Databricks cross-account access
resource "aws_iam_role_policy" "databricks_account" {
  name   = "${var.environment_name}-${var.name}-databricks-policy"
  role   = aws_iam_role.databricks_account.id
  policy = data.databricks_aws_crossaccount_policy.this.json

  lifecycle {
    ignore_changes = [policy]
  }
}

# Wait for IAM role creation before creating credentials
resource "time_sleep" "wait_iam_role" {
  depends_on      = [aws_iam_role.databricks_account, aws_iam_role_policy.databricks_account]
  create_duration = "10s"
}

# Databricks MWS Credentials
resource "databricks_mws_credentials" "this" {
  provider         = databricks.mws
  account_id       = var.databricks_account_id
  credentials_name = "${var.environment_name}-${var.name}-credentials"
  role_arn         = aws_iam_role.databricks_account.arn

  depends_on = [time_sleep.wait_iam_role]

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-${var.name}-credentials"
    Environment = var.environment_name
    Service     = "databricks"
    ManagedBy   = "terraform"
  })
}

# Databricks Storage Credentials for external data access
resource "databricks_storage_credential" "this" {
  for_each = toset(var.storage_credentials)

  name = "${var.environment_name}-${var.name}-${each.value}-credential"

  aws_iam_role {
    role_arn = aws_iam_role.databricks_account.arn
  }

  comment = "Storage credential for ${each.value} managed by Terraform"
}

# External Locations using Storage Credentials
# This resource creates external locations for external data access
resource "databricks_external_location" "this" {
  for_each = var.external_locations

  name = "${var.environment_name}-${var.name}-${each.value.name}-location"
  url  = each.value.url

  credential_name = databricks_storage_credential.this[each.value.credential].name

  comment = "External location for ${each.value.name} managed by Terraform"
}

# Metastore Data Access using Storage Credentials
resource "databricks_metastore_data_access" "storage_credentials" {
  for_each = toset(var.storage_credentials)

  metastore_id = databricks_metastore.this.id
  name         = "${var.environment_name}-${var.name}-${each.value}-data-access"

  aws_iam_role {
    role_arn = aws_iam_role.databricks_account.arn
  }

  is_default = each.value == "default"
  owner      = "account users"

  depends_on = [
    databricks_metastore.this,
    aws_iam_role.databricks_account
  ]
}
