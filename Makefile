export BOUNDARY_ADDR=$(shell cd infrastructure && terraform output -raw boundary_url)
export BOUNDARY_TLS_INSECURE=true

ad-admin-consent:
	az ad app permission grant --id $(shell cd infrastructure && terraform output -raw boundary_oidc_application_id)  --api 00000003-0000-0000-c000-000000000000

vault-init:
	bash vault-init.sh

admin:
	bash admin-login.sh

operator:
	boundary authenticate oidc -auth-method-id=$(shell cd boundary && terraform output -raw azuread_auth_method_id)

private-key:
	rm -f id_rsa.pem vault.pem
	cd infrastructure && terraform output -raw private_key | base64 -d > ../id_rsa.pem
	cd infrastructure && terraform output -raw vault_private_key | base64 -d > ../vault.pem

catalog:
	boundary hosts list -host-catalog-id $(shell cd boundary && terraform output -raw boundary_host_catalog_id)

ssh-vm:
	boundary connect ssh -target-id $(shell cd boundary && terraform output -raw vm_target_id) -username azureuser -- -i ./id_rsa.pem

boundary-connect-admin:
	boundary connect -target-id $(shell cd boundary && terraform output -raw database_admin_target_id) -listen-port 1433

boundary-connect-dev:
	boundary targets authorize-session -id $(shell cd vault && terraform output -raw boundary_database_application_target) -format json > db.json
	boundary connect -target-id $(shell cd vault && terraform output -raw boundary_database_application_target) -listen-port 1433

mssql-import:
	bash import-data.sh

debug:
	ssh -i id_rsa.pem azureuser@$(shell cd infrastructure && terraform output -raw boundary_fqdn) -p 2022

claims:
	boundary accounts list -auth-method-id $(shell cd boundary && terraform output -raw azuread_auth_method_id)
	boundary accounts read -id ${ACCOUNT_ID}

clean:
	vault lease revoke -f -prefix expense/database/mssq