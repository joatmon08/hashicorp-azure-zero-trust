variable "tfc_organization" {
  type        = string
  description = "Terraform Cloud organization to retrieve remote state for dependencies"
}

variable "application" {
  type        = string
  description = "application prefix for secrets"
}

variable "mssql_username" {
  type        = string
  description = "Username for SQL server"
  default     = "boundary"
}

variable "mssql_port" {
  type        = string
  description = "port for mysql database"
  default     = "1433"
}

data "terraform_remote_state" "infrastructure" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "infrastructure"
    }
  }
}

data "terraform_remote_state" "boundary" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "boundary"
    }
  }
}

locals {
  boundary_url                   = data.terraform_remote_state.infrastructure.outputs.boundary_url
  vault_name                     = data.terraform_remote_state.infrastructure.outputs.key_vault_name
  recovery_service_principal     = data.terraform_remote_state.infrastructure.outputs.boundary_recovery_service_principal
  host_catalog_service_principal = data.terraform_remote_state.infrastructure.outputs.boundary_host_catalog_azure_ad
  vault_url                      = data.terraform_remote_state.infrastructure.outputs.vault_url
  mssql_password                 = data.terraform_remote_state.infrastructure.outputs.mssql_password
  mssql_url                      = data.terraform_remote_state.infrastructure.outputs.mssql_url
  mssql_ip_address               = data.terraform_remote_state.infrastructure.outputs.vault_mssql_ip_address
  mssql_database_name            = data.terraform_remote_state.infrastructure.outputs.mssql_database_name
  boundary_developer_scope       = data.terraform_remote_state.boundary.outputs.developer_scope_id
  boundary_database_host_set     = data.terraform_remote_state.boundary.outputs.develoer_database_host_set_id
}