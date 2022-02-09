resource "boundary_user" "admins" {
  for_each    = var.admins
  name        = each.value
  description = "Admin user ${each.value}"
  account_ids = [boundary_account.admins[each.value].id]
  scope_id    = boundary_scope.org.id
}

resource "random_password" "admins" {
  length           = 16
  special          = true
  override_special = "_%@"
}

## Set up accounts for the admin to log in via password
resource "boundary_account" "admins" {
  for_each       = var.admins
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = random_password.admins.result
  auth_method_id = boundary_auth_method_password.password.id
}

resource "boundary_group" "admins" {
  name        = "admins"
  description = "Admin group"
  member_ids  = [for user in boundary_user.admins : user.id]
  scope_id    = boundary_scope.org.id
}

## Set up Azure AD groups for operators to log in
resource "boundary_managed_group" "operators" {
  auth_method_id = boundary_auth_method_oidc.azuread.id
  description    = "Operations team managed group"
  name           = "operators"
  filter         = "\"${local.azuread_group_ops}\" in \"/token/groups\""
}

## Set up Azure AD groups for database admins to log in
resource "boundary_managed_group" "db" {
  auth_method_id = boundary_auth_method_oidc.azuread.id
  description    = "Database team managed group"
  name           = "db-admins"
  filter         = "\"${local.azuread_group_db}\" in \"/token/groups\""
}