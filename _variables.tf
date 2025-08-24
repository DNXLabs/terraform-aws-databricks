variable "name" {
  type        = string
  description = "Name of this Databricks Account"
}

variable "environment_name" {
  type        = string
  description = "Environment name to use as a prefix to this Databricks Account"
}

variable "databricks_account_id" {
  type        = string
  description = "The Databricks Account ID"
}

variable "aws_account_id" {
  type        = string
  description = "The AWS Account ID"
}

variable "buckets" {
  type        = set(string)
  description = "Set of S3 bucket names to be created for Databricks storage. If not provided, will create a default bucket"
  default     = ["rootbucket"]
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID for Databricks network configuration"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for Databricks"
}

variable "pricing_tier" {
  type        = string
  description = "The pricing tier for the Databricks workspace"
  default     = "ENTERPRISE"
  validation {
    condition     = contains(["ENTERPRISE", "PREMIUM", "STANDARD"], var.pricing_tier)
    error_message = "Pricing tier must be one of: ENTERPRISE, PREMIUM, STANDARD."
  }
}

variable "account_name" {
  type        = string
  description = "The name for the Databricks workspace. If not provided, will use {environment_name}-{name}"
  default     = null
}

# External ID is now managed automatically in state
# No need for external_id variable - it's generated once and stored in state

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN for encryption. If not provided, default AWS managed key will be used"
  default     = null
}

variable "databricks_users" {
  type        = list(string)
  description = "List of Databricks users to be added at account-level for Unity Catalog"
  default     = []
}

variable "databricks_groups" {
  type        = map(list(string))
  description = "Map of group names to lists of user emails for group membership"
  default     = {}
}

variable "databricks_user_roles" {
  type = list(object({
    user = string
    role = string
  }))
  description = "List of user roles to assign. Each object should have 'user' (email) and 'role' (account_admin, workspace_admin, etc.)"
  default     = []
}

variable "databricks_group_roles" {
  type = list(object({
    group = string
    role  = string
  }))
  description = "List of group roles to assign. Each object should have 'group' (group name) and 'role' (account_admin, workspace_admin, etc.)"
  default     = []
}

variable "storage_credentials" {
  type        = set(string)
  description = "Set of storage credential names to be created for external data access"
  default     = []
}

variable "external_locations" {
  type = list(object({
    name       = string
    url        = string
    credential = string
  }))
  description = "List of external locations to be created. Each object should have 'name', 'url' (S3 path), and 'credential' (storage credential name)"
  default     = []
}

variable "create_service_principal" {
  type        = bool
  description = "Whether to create a service principal for this Databricks workspace"
  default     = false
}

variable "vpc_endpoints" {
  type = object({
    rest_api      = list(string)
    dataplane_relay = list(string)
  })
  description = "VPC Endpoints for Databricks (optional)"
  default = {
    rest_api      = []
    dataplane_relay = []
  }
}

variable "is_no_public_ip_enabled" {
  type        = bool
  description = "Whether to disable public IP access for the workspace"
  default     = true
}

variable "enable_private_link" {
  type        = bool
  description = "Whether to enable AWS Private Link for Databricks"
  default     = false
}

variable "private_link_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for Private Link VPC Endpoints (required if enable_private_link = true)"
  default     = []
}

variable "private_link_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs for Private Link VPC Endpoints (optional)"
  default     = []
}

variable "catalogs" {
  type = map(object({
    name        = string
    comment     = optional(string)
    properties  = optional(map(string))
    owner       = optional(string)
    schemas     = optional(map(object({
      name       = string
      comment    = optional(string)
      properties = optional(map(string))
      owner      = optional(string)
      volumes    = optional(map(object({
        name        = string
        volume_type = optional(string) # EXTERNAL, MANAGED
        comment     = optional(string)
        owner       = optional(string)
        storage_location = optional(string)
      })))
    })))
  }))
  description = "Map of catalogs to create with their schemas and volumes"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for all resources"
  default     = {}
}
