resource "boundary_credential_store_vault" "vault" {
  name            = "vault"
  description     = "Vault credentials store"
  address         = local.vault_url
  tls_skip_verify = true
  token           = vault_token.boundary.client_token
  scope_id        = local.boundary_developer_scope
}

resource "boundary_credential_library_vault" "database" {
  name                = "database"
  description         = "Vault credential library for developer database access"
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = local.boundary_creds_path
  http_method         = "GET"
}

resource "boundary_target" "db_app" {
  type                     = "tcp"
  name                     = "database"
  description              = "MSSQL Database"
  scope_id                 = local.boundary_developer_scope
  session_connection_limit = 1
  default_port             = 1433
  host_source_ids = [
    local.boundary_database_host_set
  ]
  application_credential_source_ids = [
    boundary_credential_library_vault.database.id
  ]
}