data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azuread_client_config" "current" {}

variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group"
}

variable "tags" {
  type        = map(string)
  description = "Tags to attach to infrastructure resources"
  default = {
    purpose = "hashicorp-azure-zero-trust"
  }
}

## For Virtual Network
variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  type = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "subnet_names" {
  type = list(string)
  default = [
    "controllers",
    "workers",
    "targets",
    "vault"
  ]
}

## VM count and size for Boundary SSH targets
variable "backend_vm_count" {
  type    = number
  default = 1
}

variable "backend_vm_size" {
  type    = string
  default = "Standard_D2as_v4"
}

variable "backend_vm_tags" {
  type = map(string)
  default = {
    allow = "operator"
  }
  description = "Tags to set on the Azure virtual machines for Boundary to auto-discover"
}

variable "sql_service_tag" {
  type        = string
  default     = "Sql.EastUS"
  description = "SQL service tag for location. Allows communication between VMs and Azure SQL server."
}

## Azure AD Users
variable "operators" {
  type = map(object({
    user_principal_name = string
    display_name        = string
    mail_nickname       = string
  }))
  description = "List of Boundary operator's Azure AD user attributes"
}

variable "database_admins" {
  type = map(object({
    user_principal_name = string
    display_name        = string
    mail_nickname       = string
  }))
  description = "List of Boundary database admin's Azure AD user attributes"
}

variable "database_name" {
  type        = string
  description = "Name of database for application"
}