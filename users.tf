# Databricks User Management
# This file handles Databricks user management at account level for Unity Catalog

# Databricks Account Users
resource "databricks_user" "account_users" {
  for_each = toset(var.databricks_users)

  user_name = each.value
  active    = true
}

# Databricks Account Groups
resource "databricks_group" "account_groups" {
  for_each = toset(keys(var.databricks_groups))

  display_name = each.value
}

# Add users to groups
resource "databricks_group_member" "account_group_members" {
  for_each = {
    for pair in setproduct(keys(var.databricks_groups), var.databricks_groups[pair[0]]) : "${pair[0]}-${pair[1]}" => {
      group = pair[0]
      user  = pair[1]
    }
  }

  group_id  = databricks_group.account_groups[each.value.group].id
  member_id = databricks_user.account_users[each.value.user].id

  depends_on = [
    databricks_group.account_groups,
    databricks_user.account_users
  ]
}

# User Roles - Assign roles to individual users
resource "databricks_user_role" "this" {
  for_each = toset(var.databricks_user_roles)

  user_id = databricks_user.account_users[each.value.user].id
  role    = each.value.role

  depends_on = [databricks_user.account_users]
}

# Group Roles - Assign roles to groups
resource "databricks_group_role" "this" {
  for_each = toset(var.databricks_group_roles)

  group_id = databricks_group.account_groups[each.value.group].id
  role     = each.value.role

  depends_on = [databricks_group.account_groups]
}

# Databricks Service Principal (if needed)
resource "databricks_service_principal" "this" {
  count = var.create_service_principal ? 1 : 0

  display_name = "${var.environment_name}-${var.name}-service-principal"
  active       = true
}

# Add service principal to admin group (if created)
resource "databricks_group_member" "service_principal_admin" {
  count = var.create_service_principal ? 1 : 0

  group_id  = databricks_group.account_groups["admins"].id
  member_id = databricks_service_principal.this[0].id

  depends_on = [
    databricks_group.account_groups,
    databricks_service_principal.this
  ]
}
