resource "boundary_host_catalog_plugin" "core_infra" {
  scope_id    = boundary_scope.core_infra.id
  plugin_name = "azure"
  attributes_json = jsonencode({
    disable_credential_rotation = true
    tenant_id                   = local.host_catalog_service_principal.tenant_id
    subscription_id             = local.subscription_id
    client_id                   = local.host_catalog_service_principal.client_id
  })
  secrets_json = jsonencode({
    secret_value = local.host_catalog_service_principal.client_secret
  })
}

resource "boundary_host_set_plugin" "backend" {
  host_catalog_id = boundary_host_catalog_plugin.core_infra.id
  attributes_json = jsonencode({
    filter = "tagName eq 'allow' and tagValue eq 'operator'"
  })
}

resource "boundary_target" "backend" {
  name         = "backend"
  description  = "Backend VMs"
  type         = "tcp"
  default_port = "22"
  scope_id     = boundary_scope.core_infra.id
  host_source_ids = [
    boundary_host_set_plugin.backend.id
  ]
}