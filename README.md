# terraform-aws-template

[![Lint Status](https://github.com/DNXLabs/terraform-aws-template/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-template/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-template)](https://github.com/DNXLabs/terraform-aws-template/blob/master/LICENSE)

<!--- BEGIN_TF_DOCS --->

Terraform module for creation of AWS Databricks Infrastructure with Unity Catalog support.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |
| databricks | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |
| databricks | ~> 1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment (dev, staging, prod) | `string` | n/a | yes |
| aws_account_id | AWS Account ID | `string` | n/a | yes |
| aws_region | AWS Region | `string` | `"ap-southeast-2"` | no |
| databricks_account_id | Databricks Account ID | `string` | n/a | yes |
| workspace_url | Databricks Workspace URL | `string` | n/a | yes |
| create_vpc | Whether to create a new VPC or use existing one | `bool` | `true` | no |
| vpc_id | ID of existing VPC (required if create_vpc = false) | `string` | `null` | no |
| private_subnet_ids | IDs of existing private subnets (required if create_vpc = false) | `list(string)` | `null` | no |
| vpc_name | Name of the VPC | `string` | `null` | no |
| vpc_cidr | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| availability_zones | Availability zones | `list(string)` | `["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]` | no |
| private_subnets | Private subnet CIDR blocks | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]` | no |
| public_subnets | Public subnet CIDR blocks | `list(string)` | `["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]` | no |
| metastore_bucket_name | Name of the metastore S3 bucket | `string` | `null` | no |
| workspace_bucket_name | Name of the workspace S3 bucket | `string` | `null` | no |
| create_workspace_resources | Whether to create workspace resources (clusters, pools, warehouses) | `bool` | `true` | no |
| create_catalog_resources | Whether to create catalog resources (catalogs, schemas, external locations) | `bool` | `true` | no |
| clusters_config | Configuration for Databricks clusters | `map(object)` | `{}` | no |
| instance_pools_config | Configuration for Databricks instance pools | `map(object)` | `{}` | no |
| sql_warehouses_config | Configuration for Databricks SQL warehouses | `map(object)` | `{}` | no |
| jobs_config | Configuration for Databricks jobs | `map(object)` | `{}` | no |
| catalogs_config | Configuration for Databricks catalogs | `map(object)` | `{}` | no |
| external_locations_config | Configuration for external locations | `map(object)` | `{}` | no |
| storage_credentials_config | Configuration for storage credentials | `map(object)` | `{}` | no |
| volumes_config | Configuration for volumes | `map(object)` | `{}` | no |
| tags | Tags to apply to all resources | `map(string)` | `{"ManagedBy" = "terraform"}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_cidr_block | CIDR block of the VPC |
| private_subnet_ids | IDs of the private subnets |
| public_subnet_ids | IDs of the public subnets |
| metastore_bucket_name | Name of the metastore S3 bucket |
| workspace_bucket_name | Name of the workspace S3 bucket |
| metastore_bucket_arn | ARN of the metastore S3 bucket |
| workspace_bucket_arn | ARN of the workspace S3 bucket |
| cross_account_role_arn | ARN of the cross-account IAM role |
| cross_account_role_name | Name of the cross-account IAM role |
| instance_profile_arn | ARN of the instance profile |
| instance_profile_name | Name of the instance profile |
| databricks_workspace_url | URL of the Databricks workspace |
| databricks_workspace_id | ID of the Databricks workspace |
| databricks_workspace_name | Name of the Databricks workspace |
| databricks_metastore_id | ID of the Databricks metastore |
| databricks_metastore_name | Name of the Databricks metastore |
| databricks_network_id | ID of the Databricks network |
| databricks_storage_configuration_id | ID of the Databricks storage configuration |
| databricks_credentials_id | ID of the Databricks credentials |
| cluster_ids | IDs of the created clusters |
| cluster_names | Names of the created clusters |
| instance_pool_ids | IDs of the created instance pools |
| instance_pool_names | Names of the created instance pools |
| sql_warehouse_ids | IDs of the created SQL warehouses |
| sql_warehouse_names | Names of the created SQL warehouses |
| job_ids | IDs of the created jobs |
| job_names | Names of the created jobs |
| catalog_names | Names of the created catalogs |
| catalog_ids | IDs of the created catalogs |
| schema_names | Names of the created schemas |
| schema_ids | IDs of the created schemas |
| external_location_names | Names of the created external locations |
| external_location_ids | IDs of the created external locations |
| storage_credential_names | Names of the created storage credentials |
| storage_credential_ids | IDs of the created storage credentials |
| volume_names | Names of the created volumes |
| volume_ids | IDs of the created volumes |

## Architecture

This module creates a complete Databricks infrastructure on AWS with three main components:

### 📋 **PARTE 1: ACCOUNT** - Infrastructure e Configurações de Conta
- VPC and networking
- S3 buckets for metastore and workspace
- IAM roles and policies
- Databricks workspace and metastore

### ⚙️ **PARTE 2: WORKSPACE** - Compute e Recursos de Trabalho
- Databricks clusters
- Instance pools
- SQL warehouses
- Jobs (optional)

### 📚 **PARTE 3: CATALOG** - Unity Catalog e Governança de Dados
- Catalogs (Unity Catalog)
- Schemas
- Volumes
- External locations
- Storage credentials

## Usage

### Basic Usage

```hcl
module "databricks" {
  source = "github.com/your-org/terraform-aws-databricks"

  project_name = "my-project"
  environment  = "dev"
  
  aws_account_id = "123456789012"
  databricks_account_id = "your-databricks-account-id"
  workspace_url = "https://your-workspace-url"

  # Optional: Use existing VPC
  create_vpc = false
  vpc_id = "vpc-12345678"
  private_subnet_ids = ["subnet-12345678", "subnet-87654321"]

  tags = {
    Project     = "my-project"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

### Advanced Usage with All Resources

```hcl
module "databricks" {
  source = "github.com/your-org/terraform-aws-databricks"

  project_name = "my-project"
  environment  = "prod"
  
  aws_account_id = "123456789012"
  databricks_account_id = "your-databricks-account-id"
  workspace_url = "https://your-workspace-url"

  # Clusters Configuration
  clusters_config = {
    shared = {
      cluster_name = "shared-cluster"
      spark_version = "15.4.x-scala2.12"
      node_type = "r5d.xlarge"
      num_workers = 1
      autotermination_minutes = 20
      autoscale = {
        min_workers = 1
        max_workers = 3
      }
    }
  }

  # Instance Pools Configuration
  instance_pools_config = {
    shared_pool = {
      pool_name = "shared-pool"
      node_type = "r5d.xlarge"
      min_idle_instances = 0
      max_capacity = 10
      idle_instance_autotermination_minutes = 15
    }
  }

  # SQL Warehouses Configuration
  sql_warehouses_config = {
    shared_warehouse = {
      warehouse_name = "shared-warehouse"
      cluster_size = "Small"
      auto_stop_mins = 10
      enable_serverless_compute = true
    }
  }

  # Catalogs Configuration
  catalogs_config = {
    staging = {
      name = "staging"
      comment = "Staging catalog for development"
      schemas = {
        bronze = { 
          name = "bronze" 
          comment = "Raw data layer"
        }
        silver = { 
          name = "silver" 
          comment = "Cleaned data layer"
        }
        gold = { 
          name = "gold" 
          comment = "Business-ready data layer"
        }
      }
    }
  }

  # External Locations Configuration
  external_locations_config = {
    staging_data = {
      name = "staging-external-location"
      url = "s3://my-project-staging-data/"
      credential_name = "staging-credential"
      comment = "External location for staging data"
    }
  }

  # Storage Credentials Configuration
  storage_credentials_config = {
    staging_credential = {
      name = "staging-credential"
      aws_iam_role_arn = "arn:aws:iam::123456789012:role/databricks-staging-role"
      comment = "Storage credential for staging environment"
    }
  }

  tags = {
    Project     = "my-project"
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

### Conditional Resource Creation

```hcl
module "databricks" {
  source = "github.com/your-org/terraform-aws-databricks"

  project_name = "my-project"
  environment  = "dev"
  
  aws_account_id = "123456789012"
  databricks_account_id = "your-databricks-account-id"
  workspace_url = "https://your-workspace-url"

  # Only create account resources (no compute or catalog)
  create_workspace_resources = false
  create_catalog_resources = false

  tags = {
    Project     = "my-project"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Examples

See the [examples](./examples) directory for more usage examples.

## Contributing

Please read our [Contributing Guide](./CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

<!--- END_TF_DOCS --->

## Authors

Module managed by [DNX Solutions](https://github.com/DNXLabs).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/DNXLabs/terraform-aws-template/blob/master/LICENSE) for full details.