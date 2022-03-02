locals {
  vault_role = "app"
}

resource "vault_mount" "mssql" {
  path = "${var.application}/database/mssql"
  type = "database"
}

resource "vault_database_secret_backend_connection" "mssql" {
  backend       = vault_mount.mssql.path
  name          = "mssql"
  allowed_roles = [local.vault_role]
  mssql {
    connection_url = "sqlserver://{{username}}@${local.mssql_url}:{{password}}@${local.mssql_ip_address}:${var.mssql_port}?database=${local.mssql_database_name}"
    username       = var.mssql_username
    password       = local.mssql_password
  }
}

resource "vault_database_secret_backend_role" "application" {
  backend               = vault_mount.mssql.path
  name                  = local.vault_role
  db_name               = vault_database_secret_backend_connection.mssql.name
  creation_statements   = ["CREATE USER [{{name}}] WITH PASSWORD = '{{password}}';GRANT SELECT TO [{{name}}];"]
  revocation_statements = ["DROP USER [{{name}}];"]
}