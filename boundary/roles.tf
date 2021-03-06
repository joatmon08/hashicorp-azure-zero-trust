resource "boundary_role" "global_anon_listing" {
  scope_id = boundary_scope.global.id
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}

resource "boundary_role" "org_anon_listing" {
  scope_id = boundary_scope.org.id
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}

resource "boundary_role" "global_admin" {
  scope_id = boundary_scope.global.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_group.admins.id
  ]
}

resource "boundary_role" "org_admin" {
  scope_id       = boundary_scope.global.id
  grant_scope_id = boundary_scope.org.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_group.admins.id,
  ]
}

resource "boundary_role" "org_readonly" {
  name           = "readonly"
  description    = "Read-only role"
  scope_id       = boundary_scope.global.id
  grant_scope_id = boundary_scope.org.id
  grant_strings = [
    "id=*;type=*;actions=read"
  ]
  principal_ids = [
    boundary_managed_group.operators.id,
    boundary_managed_group.db.id
  ]
}
# Adds an org-level role granting administrative permissions within the core_infra project
resource "boundary_role" "core_infra" {
  name           = "${boundary_scope.core_infra.id}-admin"
  description    = "Administrator role for ${boundary_scope.core_infra.id}"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.core_infra.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_group.admins.id,
    boundary_managed_group.operators.id
  ]
}

resource "boundary_role" "db_admin" {
  name           = "${boundary_scope.db_infra.id}-admin"
  description    = "Administrator role for ${boundary_scope.db_infra.id}"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.db_infra.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_group.admins.id,
    boundary_managed_group.db.id
  ]
}

# Adds an org-level role granting administrative permissions within the application project
resource "boundary_role" "application" {
  name           = "${boundary_scope.application.id}-admin"
  description    = "Administrator role for ${boundary_scope.application.id}"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.application.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_group.admins.id,
    boundary_managed_group.operators.id
  ]
}