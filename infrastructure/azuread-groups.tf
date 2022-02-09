locals {
  boundary_group_ops_name = "${azurerm_resource_group.resources.name}-operations-team"
  boundary_group_db_name  = "${azurerm_resource_group.resources.name}-database-team"
}

resource "random_password" "operators" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_password" "database_admins" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azuread_user" "operator" {
  for_each            = var.operators
  user_principal_name = each.value.user_principal_name
  display_name        = each.value.display_name
  mail_nickname       = each.value.mail_nickname
  password            = random_password.operators.result
}

resource "azuread_group" "operator" {
  display_name     = local.boundary_group_ops_name
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  members          = [for name, metadata in azuread_user.operator : metadata.object_id]
}

resource "azuread_user" "database" {
  for_each            = var.database_admins
  user_principal_name = each.value.user_principal_name
  display_name        = each.value.display_name
  mail_nickname       = each.value.mail_nickname
  password            = random_password.database_admins.result
}

resource "azuread_group" "database" {
  display_name     = local.boundary_group_db_name
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  members          = [for name, metadata in azuread_user.database : metadata.object_id]
}