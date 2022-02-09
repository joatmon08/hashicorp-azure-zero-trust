output "boundary_token" {
  value       = vault_token.boundary.client_token
  description = "Vault token for Boundary credentials brokering"
  sensitive   = true
}

output "boundary_database_credentials_path" {
  value       = local.boundary_creds_path
  description = "Credentials path for Boundary"
}

output "boundary_database_application_target" {
  value       = boundary_target.db_app.id
  description = "Target ID for application database access"
}