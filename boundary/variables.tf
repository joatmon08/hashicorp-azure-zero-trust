variable "tfc_organization" {
  type        = string
  description = "Terraform Cloud organization to retrieve remote state for dependencies"
}

variable "tfc_workspace" {
  type        = string
  description = "Terraform Cloud workspace to retrieve remote state for dependencies"
}

variable "organization" {
  type        = string
  description = "Name of Boundary organization"
}

variable "admins" {
  type        = set(string)
  description = "List of users for Boundary administrator access. Password authentication."
}

data "terraform_remote_state" "infrastructure" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = var.tfc_workspace
    }
  }
}

locals {
  url                            = data.terraform_remote_state.infrastructure.outputs.boundary_url
  vault_name                     = data.terraform_remote_state.infrastructure.outputs.key_vault_name
  subscription_id                = data.terraform_remote_state.infrastructure.outputs.subscription_id
  recovery_service_principal     = data.terraform_remote_state.infrastructure.outputs.boundary_recovery_service_principal
  host_catalog_service_principal = data.terraform_remote_state.infrastructure.outputs.boundary_host_catalog_azure_ad
  oidc_service_principal         = data.terraform_remote_state.infrastructure.outputs.boundary_oidc_azure_ad
  azuread_group_ops              = data.terraform_remote_state.infrastructure.outputs.boundary_azuread_group_ops
  azuread_group_db               = data.terraform_remote_state.infrastructure.outputs.boundary_azuread_group_db
  database_url                   = data.terraform_remote_state.infrastructure.outputs.mssql_ip_address
}
