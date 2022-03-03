resource "random_uuid" "oidc_user" {}
resource "random_uuid" "oidc_admin" {}
resource "random_uuid" "oidc_app_role" {}

resource "azuread_application" "oidc" {
  display_name = "${azurerm_resource_group.resources.name}-oidc-auth"
  owners       = [data.azuread_client_config.current.object_id]

  group_membership_claims = ["All"]

  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access Azure AD on behalf of the signed-in user."
      admin_consent_display_name = "Access Azure AD"
      enabled                    = true
      id                         = random_uuid.oidc_user.result
      type                       = "User"
      user_consent_description   = "Allow the application to access AzureAD on your behalf."
      user_consent_display_name  = "Access Azure AD"
      value                      = "user_impersonation"
    }

    oauth2_permission_scope {
      admin_consent_description  = "Administer the Boundary OIDC auth method application"
      admin_consent_display_name = "Administer"
      enabled                    = true
      id                         = random_uuid.oidc_admin.result
      type                       = "Admin"
      value                      = "administer"
    }
  }

  app_role {
    allowed_member_types = ["User", "Application"]
    description          = "Admins can manage roles and perform all task actions"
    display_name         = "Admin"
    enabled              = true
    id                   = random_uuid.oidc_app_role.result
    value                = "admin"
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = "Role"
    }

    resource_access {
      id   = "b4e74841-8e56-480b-be8b-910348b18b4c" # User.ReadWrite
      type = "Scope"
    }

    resource_access {
      id   = "98830695-27a2-44f7-8c18-0c3ebc9698f6" # GroupMember.Read.All
      type = "Role"
    }
  }

  web {
    redirect_uris = ["${module.install.url}/v1/auth-methods/oidc:authenticate:callback"]
  }
}

resource "azuread_application_password" "oidc" {
  application_object_id = azuread_application.oidc.object_id
  display_name          = "Boundary secret"
}

resource "azuread_service_principal" "oidc" {
  application_id = azuread_application.oidc.application_id
  owners         = [data.azuread_client_config.current.object_id]
}