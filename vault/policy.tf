locals {
  boundary_creds_path = "${vault_mount.mssql.path}/creds/${vault_database_secret_backend_role.application.name}"
}

data "vault_policy_document" "boundary_controller" {
  rule {
    path         = "auth/token/lookup-self"
    capabilities = ["read"]
  }

  rule {
    path         = "auth/token/renew-self"
    capabilities = ["update"]
  }

  rule {
    path         = "auth/token/revoke-self"
    capabilities = ["update"]
  }

  rule {
    path         = "sys/leases/renew"
    capabilities = ["update"]
  }

  rule {
    path         = "sys/leases/revoke"
    capabilities = ["update"]
  }

  rule {
    path         = "sys/capabilities-self"
    capabilities = ["update"]
  }
}

resource "vault_policy" "boundary_controller" {
  name   = "boundary-controller"
  policy = data.vault_policy_document.boundary_controller.hcl
}

data "vault_policy_document" "boundary_product" {
  rule {
    path         = local.boundary_creds_path
    capabilities = ["read"]
    description  = "read credentials for expense database"
  }
}

resource "vault_policy" "boundary_product" {
  name   = "boundary"
  policy = data.vault_policy_document.boundary_product.hcl
}

resource "vault_token" "boundary" {
  role_name = vault_token_auth_backend_role.boundary.role_name
  policies = [
    vault_policy.boundary_product.name,
    vault_policy.boundary_controller.name
  ]
  period = "24h"
}

resource "vault_token_auth_backend_role" "boundary" {
  role_name = "boundary"
  allowed_policies = [
    vault_policy.boundary_product.name,
    vault_policy.boundary_controller.name
  ]
  disallowed_policies = ["default"]
  orphan              = true
  renewable           = true
}
