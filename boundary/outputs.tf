output "password_auth_method_id" {
  value       = boundary_auth_method_password.password.id
  description = "Password auth method ID for Boundary's administrators"
}

output "azuread_auth_method_id" {
  value       = boundary_auth_method_oidc.azuread.id
  description = "Azure AD auth method ID for Boundary's operators"
}

output "admin_password" {
  value       = random_password.admins.result
  sensitive   = true
  description = "Password for Boundary's administrators"
}

output "boundary_host_catalog_id" {
  value       = boundary_host_catalog_plugin.core_infra.id
  description = "Host catalog ID for Boundary's auto-discovery of backend VMs based on tags"
}

output "vm_target_id" {
  value       = boundary_target.backend.id
  description = "Target ID for Boundary's auto-discovery of backend VMs based on tags"
}

output "database_admin_target_id" {
  value       = boundary_target.db_admin.id
  description = "Target ID for static MSSQL endpoint for database admins"
}

output "developer_scope_id" {
  value       = boundary_scope.application.id
  description = "Scope ID for developers accessing applications"
}

output "develoer_database_host_set_id" {
  value       = boundary_host_set_static.db_app.id
  description = "Host set ID for developers accessing database"
}