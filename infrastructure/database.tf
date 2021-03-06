resource "random_password" "database" {
  length           = 16
  special          = true
  override_special = "!$#%"
}

resource "azurerm_mssql_server" "database" {
  depends_on                    = [module.install]
  name                          = "${azurerm_resource_group.resources.name}-database"
  resource_group_name           = azurerm_resource_group.resources.name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = "boundary"
  administrator_login_password  = random_password.database.result
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  dynamic "azuread_administrator" {
    for_each = azuread_user.database
    content {
      login_username = azuread_administrator.value.user_principal_name
      object_id      = azuread_administrator.value.object_id
    }
  }

  tags = var.tags
}

resource "azurerm_mssql_database" "database" {
  name      = var.database_name
  server_id = azurerm_mssql_server.database.id
  sku_name  = "Basic"
  tags      = var.tags
}

resource "azurerm_private_endpoint" "boundary" {
  depends_on          = [azurerm_mssql_server.database]
  name                = "${azurerm_resource_group.resources.name}-boundary"
  resource_group_name = azurerm_resource_group.resources.name
  location            = var.location
  subnet_id           = local.worker_subnet_id

  private_service_connection {
    name                           = "${azurerm_resource_group.resources.name}-boundary"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.database.id
    subresource_names              = ["sqlServer"]
  }
}

resource "azurerm_private_endpoint" "vault" {
  depends_on          = [azurerm_mssql_server.database]
  name                = "${azurerm_resource_group.resources.name}-vault"
  resource_group_name = azurerm_resource_group.resources.name
  location            = var.location
  subnet_id           = local.vault_subnet_id

  private_service_connection {
    name                           = "${azurerm_resource_group.resources.name}-vault"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.database.id
    subresource_names              = ["sqlServer"]
  }
}
