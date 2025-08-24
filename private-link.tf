# AWS Private Link for Databricks
# This file handles AWS Private Link configuration for enhanced security

# VPC Endpoint for Databricks REST API
resource "aws_vpc_endpoint" "databricks_rest_api" {
  count = var.enable_private_link ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.vpce.${data.aws_region.current.name}.vpce-svc-0da0c1d6aa62c309c"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_link_subnet_ids
  security_group_ids  = var.private_link_security_group_ids

  private_dns_enabled = true

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-${var.name}-databricks-rest-api-vpce"
    Environment = var.environment_name
    Service     = "databricks"
    ManagedBy   = "terraform"
    Type        = "private-link"
  })
}

# VPC Endpoint for Databricks Dataplane Relay
resource "aws_vpc_endpoint" "databricks_dataplane_relay" {
  count = var.enable_private_link ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.vpce.${data.aws_region.current.name}.vpce-svc-0da0c1d6aa62c309c"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_link_subnet_ids
  security_group_ids  = var.private_link_security_group_ids

  private_dns_enabled = true

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-${var.name}-databricks-dataplane-relay-vpce"
    Environment = var.environment_name
    Service     = "databricks"
    ManagedBy   = "terraform"
    Type        = "private-link"
  })
}

# Security Group for Private Link VPC Endpoints (if not provided)
resource "aws_security_group" "private_link" {
  count = var.enable_private_link && length(var.private_link_security_group_ids) == 0 ? 1 : 0

  name_prefix = "${var.environment_name}-${var.name}-private-link-"
  vpc_id      = var.vpc_id

  # Allow HTTPS inbound from Databricks subnets
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks.id]
    description     = "HTTPS from Databricks security group"
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-${var.name}-private-link-sg"
    Environment = var.environment_name
    Service     = "databricks"
    ManagedBy   = "terraform"
    Type        = "private-link"
  })
}

# Wait for VPC Endpoints to be ready
resource "time_sleep" "wait_private_link" {
  count = var.enable_private_link ? 1 : 0

  depends_on = [
    aws_vpc_endpoint.databricks_rest_api,
    aws_vpc_endpoint.databricks_dataplane_relay
  ]
  create_duration = "30s"
}
