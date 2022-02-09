terraform {
  required_version = ">=1.0.0"
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "~>1.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.3.1"
    }
  }
}

provider "vault" {
  address         = local.vault_url
  skip_tls_verify = true
}

provider "boundary" {
  addr             = local.boundary_url
  tls_insecure     = true
  recovery_kms_hcl = <<EOT
kms "azurekeyvault" {
    purpose = "recovery"
	tenant_id     = "${local.recovery_service_principal.tenant_id}"
    client_id = "${local.recovery_service_principal.client_id}"
    client_secret = "${local.recovery_service_principal.client_secret}"
    vault_name = "${local.vault_name}"
    key_name = "recovery"
}
EOT
}