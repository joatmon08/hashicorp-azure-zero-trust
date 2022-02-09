resource "azuread_application" "boundary_host" {
  display_name = "${azurerm_resource_group.resources.name}-host-catalog"
  owners       = [data.azuread_client_config.current.object_id]

  app_role {
    allowed_member_types = ["Application"]
    description          = "Reader role enabling app to read subscription details"
    display_name         = "Reader"
    enabled              = true
    id                   = "1b19509b-32b1-4e9f-b71d-4992aa991967"
    value                = "Read.All"
  }
}

resource "azuread_application_password" "boundary_host" {
  application_object_id = azuread_application.boundary_host.object_id
  display_name          = "Boundary secret"
}

resource "azuread_service_principal" "boundary_host" {
  application_id = azuread_application.boundary_host.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azurerm_role_assignment" "boundary_host" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.boundary_host.object_id
}