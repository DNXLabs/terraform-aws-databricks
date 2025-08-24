# Databricks Metastore Configuration
# This file handles the Databricks metastore configuration for Unity Catalog

# Use rootbucket for metastore storage (defined in account.tf)

# Databricks Metastore
resource "databricks_metastore" "this" {
  name          = "${var.environment_name}-${var.name}-metastore"
  force_destroy = true

  storage_root = "s3://${aws_s3_bucket.databricks_storage[local.root_bucket_key].bucket}/metastore"

  owner = "account users"
}

# Wait for metastore creation
resource "time_sleep" "wait_metastore" {
  depends_on      = [databricks_metastore.this]
  create_duration = "20s"
}

# Databricks Metastore Data Access
resource "databricks_metastore_data_access" "this" {
  metastore_id = databricks_metastore.this.id
  name         = aws_iam_role.databricks_account.name

  aws_iam_role {
    role_arn = aws_iam_role.databricks_account.arn
  }

  is_default = true
  owner      = "account users"

  depends_on = [
    time_sleep.wait_metastore,
    aws_iam_role.databricks_account
  ]
}
