# Validations for Databricks module
# This file contains essential validation rules

# Validate that rootbucket is always included
check "rootbucket_included" {
  assert {
    condition     = contains(var.buckets, "rootbucket")
    error_message = "The 'rootbucket' must always be included in the buckets list"
  }
}

# Validate pricing tier
check "pricing_tier_valid" {
  assert {
    condition     = contains(["ENTERPRISE", "PREMIUM", "STANDARD"], var.pricing_tier)
    error_message = "Pricing tier must be one of: ENTERPRISE, PREMIUM, STANDARD"
  }
}

# Validate external locations reference valid credentials
check "external_locations_credentials" {
  assert {
    condition = alltrue([
      for location in var.external_locations :
      contains(var.storage_credentials, location.credential)
    ])
    error_message = "All external locations must reference valid storage credentials"
  }
}

# Validate Private Link configuration
check "private_link_subnets" {
  assert {
    condition     = !var.enable_private_link || length(var.private_link_subnet_ids) > 0
    error_message = "private_link_subnet_ids must be provided when enable_private_link is true"
  }
}

# Validate Private Link subnets are in the same VPC
check "private_link_subnet_vpc" {
  assert {
    condition = !var.enable_private_link || alltrue([
      for subnet_id in var.private_link_subnet_ids :
      can(regex("^subnet-", subnet_id))
    ])
    error_message = "All private_link_subnet_ids must be valid subnet IDs"
  }
}
