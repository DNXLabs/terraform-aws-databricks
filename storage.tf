# Databricks MWS Storage Configuration
# This file handles the Databricks storage configuration

# Generate bucket names if not provided
locals {
  bucket_names = {
    for bucket in var.buckets : bucket => "${var.environment_name}-${var.name}-${bucket}-${random_string.bucket_suffix.result}"
  }
}

# Random string for bucket name suffix
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Buckets for Databricks storage
resource "aws_s3_bucket" "databricks_storage" {
  for_each = var.buckets
  bucket   = local.bucket_names[each.value]

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-${var.name}-${each.value}-storage-bucket"
    Environment = var.environment_name
    Service     = "databricks"
    ManagedBy   = "terraform"
    BucketType  = each.value
  })
}

# S3 Bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "databricks_storage" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.databricks_storage[each.value].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "databricks_storage" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.databricks_storage[each.value].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Official Databricks S3 bucket policy data source
data "databricks_aws_bucket_policy" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.databricks_storage[each.value].bucket
}

# S3 Bucket policy for Databricks access
resource "aws_s3_bucket_policy" "databricks_storage" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.databricks_storage[each.value].id
  policy   = data.databricks_aws_bucket_policy.this[each.value].json

  depends_on = [aws_s3_bucket_public_access_block.databricks_storage]
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "databricks_storage" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.databricks_storage[each.value].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Databricks MWS Storage Configuration
resource "databricks_mws_storage_configurations" "this" {
  for_each                   = var.buckets
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  storage_configuration_name = "${var.environment_name}-${var.name}-${each.value}-storage"
  bucket_name                = aws_s3_bucket.databricks_storage[each.value].bucket

  depends_on = [
    aws_s3_bucket_policy.databricks_storage,
    aws_s3_bucket_versioning.databricks_storage
  ]

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-${var.name}-${each.value}-storage"
    Environment = var.environment_name
    Service     = "databricks"
    ManagedBy   = "terraform"
    BucketType  = each.value
  })
}
