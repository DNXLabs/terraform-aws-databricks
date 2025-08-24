# Databricks MWS Network Configuration
# This file handles the Databricks network configuration and security groups

# Security Group for Databricks
resource "aws_security_group" "databricks" {
  name_prefix = "${var.environment_name}-${var.name}-databricks-"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-${var.name}-databricks-sg"
    Environment = var.environment_name
    Service     = "databricks"
    ManagedBy   = "terraform"
  })
}

# Databricks MWS Network Configuration
resource "databricks_mws_networks" "this" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "${var.environment_name}-${var.name}-network"
  vpc_id             = var.vpc_id
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.databricks.id]

  # VPC Endpoints configuration
  dynamic "vpc_endpoints" {
    for_each = var.enable_private_link ? [1] : []
    content {
      rest_api      = [aws_vpc_endpoint.databricks_rest_api[0].id]
      dataplane_relay = [aws_vpc_endpoint.databricks_dataplane_relay[0].id]
    }
  }

  # Legacy VPC endpoints (if not using private link)
  dynamic "vpc_endpoints" {
    for_each = !var.enable_private_link && (length(var.vpc_endpoints.rest_api) > 0 || length(var.vpc_endpoints.dataplane_relay) > 0) ? [1] : []
    content {
      rest_api      = var.vpc_endpoints.rest_api
      dataplane_relay = var.vpc_endpoints.dataplane_relay
    }
  }

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-${var.name}-network"
    Environment = var.environment_name
    Service     = "databricks"
    ManagedBy   = "terraform"
  })
}