# terraform-aws-databricks

[![Lint Status](https://github.com/DNXLabs/terraform-aws-databricks/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-databricks/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-databricks)](https://github.com/DNXLabs/terraform-aws-databricks/blob/master/LICENSE)

<!--- BEGIN_TF_DOCS --->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 4.0.0 |
| databricks | >= 1.0.0 |
| random | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0.0 |
| databricks | >= 1.0.0 |
| random | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of this Databricks workspace | `string` | n/a | yes |
| environment_name | Environment name to use as a prefix | `string` | n/a | yes |
| databricks_account_id | The Databricks Account ID | `string` | n/a | yes |
| aws_account_id | The AWS Account ID | `string` | n/a | yes |
| buckets | Set of S3 bucket names for Databricks storage | `set(string)` | `["rootbucket"]` | no |
| vpc_id | The VPC ID for Databricks network | `string` | n/a | yes |
| private_subnet_ids | List of private subnet IDs | `list(string)` | n/a | yes |
| pricing_tier | The pricing tier for Databricks | `string` | `"ENTERPRISE"` | no |
| account_name | Custom workspace name (optional) | `string` | `null` | no |
| kms_key_arn | KMS Key ARN for encryption | `string` | `null` | no |
| databricks_users | List of Databricks users | `list(string)` | `[]` | no |
| databricks_groups | Map of group names to user lists | `map(list(string))` | `{}` | no |
| databricks_user_roles | List of user role assignments | `list(object)` | `[]` | no |
| databricks_group_roles | List of group role assignments | `list(object)` | `[]` | no |
| storage_credentials | Set of storage credential names | `set(string)` | `[]` | no |
| external_locations | List of external locations | `list(object)` | `[]` | no |
| create_service_principal | Whether to create service principal | `bool` | `false` | no |
| tags | Additional tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| workspace_id | The Databricks Workspace ID |
| workspace_url | The Databricks Workspace URL |
| workspace_name | The Databricks Workspace name |
| iam_role_arn | The ARN of the IAM role created for Databricks |
| iam_role_name | The name of the IAM role created for Databricks |
| external_id | The external ID used for the IAM role |
| credentials_id | The ID of the Databricks credentials |
| storage_configuration_id | The ID of the Databricks storage configuration |
| network_id | The ID of the Databricks network configuration |
| security_group_id | The ID of the Databricks security group |
| metastore_id | The ID of the Databricks metastore |
| s3_buckets | Map of bucket names to their S3 bucket information |
| root_bucket_name | The name of the root S3 bucket |
| root_bucket_arn | The ARN of the root S3 bucket |
| user_ids | Map of user emails to their Databricks user IDs |
| group_ids | Map of group names to their Databricks group IDs |
| storage_credentials | Map of storage credential names to their information |
| external_locations | List of external locations created |
| service_principal_id | The ID of the service principal (if created) |
| state_info | Information about state management |
| resource_summary | Summary of all resources created |

<!--- END_TF_DOCS --->

## Usage

### Basic Usage

```hcl
module "databricks_workspace" {
  source = "git::https://github.com/DNXLabs/terraform-aws-databricks.git?ref=1.0.0"

  name                        = "my-databricks"
  environment_name           = "prod"
  databricks_account_id      = "your-databricks-account-id"
  aws_account_id             = "123456789012"
  vpc_id                     = "vpc-12345678"
  private_subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  # external_id is managed automatically in state
}
```

### Advanced Usage

```hcl
module "databricks_workspace" {
  source = "git::https://github.com/DNXLabs/terraform-aws-databricks.git?ref=1.0.0"

  name                        = "my-databricks"
  environment_name           = "prod"
  databricks_account_id      = "your-databricks-account-id"
  aws_account_id             = "123456789012"
  vpc_id                     = "vpc-12345678"
  private_subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  pricing_tier               = "PREMIUM"
  account_name               = "My Custom Databricks Workspace"
  # external_id is managed automatically in state
  kms_key_arn                = "arn:aws:kms:us-east-1:123456789012:key/my-key"

  # Multiple storage buckets
  buckets = ["rootbucket", "data", "logs"]

  # User and group management
  databricks_users = ["user1@company.com", "user2@company.com"]
  databricks_groups = {
    "admins" = ["admin@company.com"]
    "users"  = ["user1@company.com", "user2@company.com"]
  }

  # Storage credentials and external locations
  storage_credentials = ["s3-credential"]
  external_locations = [
    {
      name       = "external-data"
      url        = "s3://my-external-bucket/data/"
      credential = "s3-credential"
    }
  ]

  # Unity Catalog - Catalogs, Schemas and Volumes
  catalogs = {
    main = {
      name    = "main"
      comment = "Main catalog for production data"
      owner   = "account users"
      schemas = {
        raw = {
          name    = "raw"
          comment = "Raw data schema"
          owner   = "account users"
          volumes = {
            raw_data = {
              name        = "raw_data"
              volume_type = "MANAGED"
              comment     = "Volume for raw data"
              owner       = "account users"
            }
            external_data = {
              name        = "external_data"
              volume_type = "EXTERNAL"
              comment     = "Volume for external data"
              owner       = "account users"
              storage_location = "s3://my-external-bucket/volumes/external_data/"
            }
          }
        }
        processed = {
          name    = "processed"
          comment = "Processed data schema"
          owner   = "account users"
          volumes = {
            processed_data = {
              name        = "processed_data"
              volume_type = "MANAGED"
              comment     = "Volume for processed data"
              owner       = "account users"
            }
          }
        }
      }
    }
  }

  # AWS Private Link (optional - enhanced security)
  enable_private_link = true
  private_link_subnet_ids = ["subnet-private-link-1", "subnet-private-link-2"]
  # private_link_security_group_ids = ["sg-private-link"] # Optional: use custom security groups

  # Legacy VPC Endpoints (optional - if not using Private Link)
  # vpc_endpoints = {
  #   rest_api      = ["vpce-12345678"]
  #   dataplane_relay = ["vpce-87654321"]
  # }

  # Security settings
  is_no_public_ip_enabled = true

  tags = {
    Owner       = "Data Team"
    CostCenter  = "Data Engineering"
    Project     = "Data Platform"
  }
}
```

### Unity Catalog Usage

```hcl
module "databricks_workspace" {
  source = "git::https://github.com/DNXLabs/terraform-aws-databricks.git?ref=1.0.0"

  name                        = "my-databricks"
  environment_name           = "prod"
  databricks_account_id      = "your-databricks-account-id"
  aws_account_id             = "123456789012"
  vpc_id                     = "vpc-12345678"
  private_subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  
  # Unity Catalog with Catalogs, Schemas and Volumes
  catalogs = {
    # Main catalog for production data
    main = {
      name    = "main"
      comment = "Main catalog for production data"
      owner   = "account users"
      
      schemas = {
        # Raw data schema
        raw = {
          name    = "raw"
          comment = "Raw data schema"
          owner   = "account users"
          
          volumes = {
            # Managed volume for raw data
            raw_data = {
              name        = "raw_data"
              volume_type = "MANAGED"
              comment     = "Volume for raw data"
              owner       = "account users"
            }
            
            # External volume with S3 storage
            external_data = {
              name        = "external_data"
              volume_type = "EXTERNAL"
              comment     = "Volume for external data"
              owner       = "account users"
              storage_location = "s3://my-external-bucket/volumes/external_data/"
            }
          }
        }
        
        # Processed data schema
        processed = {
          name    = "processed"
          comment = "Processed data schema"
          owner   = "account users"
          
          volumes = {
            processed_data = {
              name        = "processed_data"
              volume_type = "MANAGED"
              comment     = "Volume for processed data"
              owner       = "account users"
            }
          }
        }
      }
    }
    
    # Analytics catalog
    analytics = {
      name    = "analytics"
      comment = "Analytics catalog for reporting"
      owner   = "account users"
      
      schemas = {
        reports = {
          name    = "reports"
          comment = "Reports schema"
          owner   = "account users"
          
          volumes = {
            reports_data = {
              name        = "reports_data"
              volume_type = "MANAGED"
              comment     = "Volume for reports data"
              owner       = "account users"
            }
          }
        }
      }
    }
  }

  tags = {
    Owner       = "Data Team"
    CostCenter  = "Data Engineering"
    Project     = "Data Platform"
  }
}
```

### Private Link Usage

```hcl
module "databricks_workspace" {
  source = "git::https://github.com/DNXLabs/terraform-aws-databricks.git?ref=1.0.0"

  name                        = "my-databricks"
  environment_name           = "prod"
  databricks_account_id      = "your-databricks-account-id"
  aws_account_id             = "123456789012"
  vpc_id                     = "vpc-12345678"
  private_subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  
  # Enable AWS Private Link for enhanced security
  enable_private_link = true
  private_link_subnet_ids = ["subnet-private-link-1", "subnet-private-link-2"]
  
  # Security settings
  is_no_public_ip_enabled = true

  tags = {
    Owner       = "Data Team"
    CostCenter  = "Data Engineering"
    Project     = "Data Platform"
    Security    = "Private Link Enabled"
  }
}
```
```

## Features

- **Databricks Workspace Management**: Complete Databricks workspace setup and configuration
- **Multiple S3 Buckets**: Support for multiple storage buckets with automatic naming
- **User and Group Management**: Automated user and group creation with role assignments
- **Storage Credentials**: External storage credential management for data access
- **External Locations**: Configuration of external data locations
- **Unity Catalog**: Metastore setup for data governance
- **Catalogs & Schemas**: Automated catalog and schema creation
- **Volumes**: Managed and external volume support
- **Security**: IAM roles with external ID protection and security groups
- **AWS Private Link**: Optional Private Link for enhanced security and compliance
- **VPC Endpoints**: Optional VPC endpoints for enhanced security
- **Public IP Control**: Option to disable public IP access
- **State Management**: Automatic external ID management in Terraform state
- **IAM Integration**: Automatic IAM role and policy creation with proper permissions
- **State Management**: Optimized for S3 backend storage with automatic External ID management
- **Security**: External ID support for enhanced security
- **Encryption**: KMS key integration for data encryption
- **Tagging**: Comprehensive resource tagging support with state management tags
- **Flexible Configuration**: Support for different pricing tiers and custom naming
- **Built-in Validations**: Configuration integrity checks and resource validation
- **Data Sources**: AWS resource validation and information gathering

## Security

This module creates an IAM role with the minimum required permissions for Databricks to operate:

- EC2 permissions for VPC endpoint management
- S3 permissions for storage access
- KMS permissions for encryption (if KMS key is provided)
- Secrets Manager permissions for accessing configuration

All sensitive configuration data is stored securely in AWS Secrets Manager, including:
- Databricks Account ID
- AWS Account ID
- External ID (auto-generated if not provided)
- Network and storage configuration
- KMS key information

The IAM role uses an external ID for enhanced security, which is automatically generated on first deployment and stored in Secrets Manager for future deployments.

## Contributing

Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.