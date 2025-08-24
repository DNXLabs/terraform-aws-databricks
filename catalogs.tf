# Databricks Unity Catalog - Catalogs and Schemas
# This file handles the creation of catalogs and schemas within the metastore

# Wait for metastore to be ready before creating catalogs
resource "time_sleep" "wait_metastore_ready" {
  depends_on = [databricks_metastore.this]
  create_duration = "30s"
}

# Databricks Catalogs
resource "databricks_catalog" "this" {
  for_each = var.catalogs

  name    = each.value.name
  comment = each.value.comment != null ? each.value.comment : "Catalog ${each.value.name} managed by Terraform"
  owner   = each.value.owner != null ? each.value.owner : "account users"

  depends_on = [time_sleep.wait_metastore_ready]
}

# Databricks Schemas within Catalogs
resource "databricks_schema" "this" {
  for_each = {
    for pair in setproduct(
      keys(var.catalogs),
      each.value.schemas != null ? keys(each.value.schemas) : []
    ) : "${pair[0]}.${pair[1]}" => {
      catalog_name = pair[0]
      schema_name  = pair[1]
      schema_config = var.catalogs[pair[0]].schemas[pair[1]]
    }
  }

  catalog_name = each.value.catalog_name
  name         = each.value.schema_config.name
  comment      = each.value.schema_config.comment != null ? each.value.schema_config.comment : "Schema ${each.value.schema_config.name} managed by Terraform"
  owner        = each.value.schema_config.owner != null ? each.value.schema_config.owner : "account users"

  depends_on = [databricks_catalog.this]
}

# Databricks Volumes within Schemas
resource "databricks_volume" "this" {
  for_each = {
    for triple in setproduct(
      keys(var.catalogs),
      each.value.schemas != null ? keys(each.value.schemas) : [],
      each.value.schemas != null && each.value.schemas[triple[1]].volumes != null ? keys(each.value.schemas[triple[1]].volumes) : []
    ) : "${triple[0]}.${triple[1]}.${triple[2]}" => {
      catalog_name = triple[0]
      schema_name  = triple[1]
      volume_name  = triple[2]
      volume_config = var.catalogs[triple[0]].schemas[triple[1]].volumes[triple[2]]
    }
  }

  catalog_name = each.value.catalog_name
  schema_name  = each.value.schema_name
  name         = each.value.volume_config.name
  volume_type  = each.value.volume_config.volume_type != null ? each.value.volume_config.volume_type : "MANAGED"
  comment      = each.value.volume_config.comment != null ? each.value.volume_config.comment : "Volume ${each.value.volume_config.name} managed by Terraform"
  owner        = each.value.volume_config.owner != null ? each.value.volume_config.owner : "account users"

  # Storage location for EXTERNAL volumes
  storage_location = each.value.volume_config.volume_type == "EXTERNAL" && each.value.volume_config.storage_location != null ? each.value.volume_config.storage_location : null
}
