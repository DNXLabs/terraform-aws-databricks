output "workspace_id" {
  description = "The Databricks Workspace ID"
  value       = databricks_mws_workspaces.this.workspace_id
}

output "workspace_url" {
  description = "The Databricks Workspace URL"
  value       = databricks_mws_workspaces.this.workspace_url
}

output "workspace_name" {
  description = "The Databricks Workspace name"
  value       = databricks_mws_workspaces.this.workspace_name
}

output "iam_role_arn" {
  description = "The ARN of the IAM role created for Databricks"
  value       = aws_iam_role.databricks_account.arn
}

output "iam_role_name" {
  description = "The name of the IAM role created for Databricks"
  value       = aws_iam_role.databricks_account.name
}

output "external_id" {
  description = "The external ID used for the IAM role"
  value       = local.external_id
}



output "credentials_id" {
  description = "The ID of the Databricks credentials"
  value       = databricks_mws_credentials.this.credentials_id
}

output "storage_configuration_id" {
  description = "The ID of the Databricks storage configuration (rootbucket)"
  value       = databricks_mws_storage_configurations.this["rootbucket"].storage_configuration_id
}

output "network_id" {
  description = "The ID of the Databricks network configuration"
  value       = databricks_mws_networks.this.network_id
}

output "security_group_id" {
  description = "The ID of the Databricks security group"
  value       = aws_security_group.databricks.id
}

output "metastore_id" {
  description = "The ID of the Databricks metastore"
  value       = databricks_metastore.this.id
}

output "s3_buckets" {
  description = "Map of bucket names to their S3 bucket information"
  value = {
    for bucket in var.buckets : bucket => {
      bucket_name              = aws_s3_bucket.databricks_storage[bucket].bucket
      bucket_arn               = aws_s3_bucket.databricks_storage[bucket].arn
      storage_configuration_id = databricks_mws_storage_configurations.this[bucket].storage_configuration_id
    }
  }
}

output "root_bucket_name" {
  description = "The name of the root S3 bucket used for Databricks storage"
  value       = aws_s3_bucket.databricks_storage["rootbucket"].bucket
}

output "root_bucket_arn" {
  description = "The ARN of the root S3 bucket used for Databricks storage"
  value       = aws_s3_bucket.databricks_storage["rootbucket"].arn
}

output "user_ids" {
  description = "Map of user emails to their Databricks user IDs"
  value       = { for email, user in databricks_user.account_users : email => user.id }
}

output "group_ids" {
  description = "Map of group names to their Databricks group IDs"
  value       = { for name, group in databricks_group.account_groups : name => group.id }
}

output "user_roles" {
  description = "List of user roles assigned"
  value       = var.databricks_user_roles
}

output "group_roles" {
  description = "List of group roles assigned"
  value       = var.databricks_group_roles
}

output "storage_credentials" {
  description = "Map of storage credential names to their information"
  value = {
    for credential in var.storage_credentials : credential => {
      name = databricks_storage_credential.this[credential].name
      id   = databricks_storage_credential.this[credential].id
    }
  }
}

output "external_locations" {
  description = "List of external locations created"
  value       = var.external_locations
}

output "service_principal_id" {
  description = "The ID of the service principal (if created)"
  value       = var.create_service_principal ? databricks_service_principal.this[0].id : null
}

output "state_info" {
  description = "Information about state management for this Databricks workspace"
  value = {
    external_id   = local.external_id
    workspace_id  = databricks_mws_workspaces.this.workspace_id
    workspace_url = databricks_mws_workspaces.this.workspace_url
  }
}

output "private_link_vpc_endpoints" {
  description = "VPC Endpoint IDs for Private Link (if enabled)"
  value = var.enable_private_link ? {
    rest_api_vpce_id      = aws_vpc_endpoint.databricks_rest_api[0].id
    dataplane_relay_vpce_id = aws_vpc_endpoint.databricks_dataplane_relay[0].id
    rest_api_dns_name     = aws_vpc_endpoint.databricks_rest_api[0].dns_entry[0]["dns_name"]
    dataplane_relay_dns_name = aws_vpc_endpoint.databricks_dataplane_relay[0].dns_entry[0]["dns_name"]
  } : null
}

output "private_link_security_group_id" {
  description = "Security Group ID for Private Link VPC Endpoints (if created)"
  value       = var.enable_private_link && length(var.private_link_security_group_ids) == 0 ? aws_security_group.private_link[0].id : null
}

output "catalogs" {
  description = "Map of catalog names to their information"
  value = {
    for catalog_name, catalog in databricks_catalog.this : catalog_name => {
      name    = catalog.name
      id      = catalog.id
      comment = catalog.comment
      owner   = catalog.owner
    }
  }
}

output "schemas" {
  description = "Map of schema names to their information"
  value = {
    for schema_key, schema in databricks_schema.this : schema_key => {
      catalog_name = schema.catalog_name
      name         = schema.name
      id           = schema.id
      comment      = schema.comment
      owner        = schema.owner
    }
  }
}

output "volumes" {
  description = "Map of volume names to their information"
  value = {
    for volume_key, volume in databricks_volume.this : volume_key => {
      catalog_name = volume.catalog_name
      schema_name  = volume.schema_name
      name         = volume.name
      id           = volume.id
      volume_type  = volume.volume_type
      comment      = volume.comment
      owner        = volume.owner
    }
  }
}

output "resource_summary" {
  description = "Summary of all resources created by this module"
  value = {
    s3_buckets_count          = length(var.buckets)
    users_count               = length(var.databricks_users)
    groups_count              = length(keys(var.databricks_groups))
    storage_credentials_count = length(var.storage_credentials)
    external_locations_count  = length(var.external_locations)
    service_principal_created = var.create_service_principal
    vpc_endpoints_configured  = length(var.vpc_endpoints.rest_api) > 0 || length(var.vpc_endpoints.dataplane_relay) > 0
    public_ip_disabled        = var.is_no_public_ip_enabled
    private_link_enabled      = var.enable_private_link
    catalogs_count            = length(var.catalogs)
    schemas_count             = length(databricks_schema.this)
    volumes_count             = length(databricks_volume.this)
  }
}
