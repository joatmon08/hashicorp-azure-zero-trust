resource "boundary_auth_method_password" "password" {
  name        = "Password"
  description = "Password auth method for ${var.organization}"
  scope_id    = boundary_scope.org.id
}

resource "boundary_auth_method_oidc" "azuread" {
  name                 = "Azure AD"
  description          = "Azure AD auth method for ${var.organization}"
  scope_id             = boundary_scope.org.id
  issuer               = local.oidc_service_principal.issuer
  client_id            = local.oidc_service_principal.client_id
  client_secret        = local.oidc_service_principal.client_secret
  signing_algorithms   = ["RS256"]
  api_url_prefix       = local.url
  is_primary_for_scope = true
  state                = "active-public"
}