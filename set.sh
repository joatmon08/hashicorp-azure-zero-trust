export BOUNDARY_ADDR=$(cd infrastructure && terraform output -raw boundary_url)
export BOUNDARY_TLS_INSECURE=true
export VAULT_ADDR=$(cd infrastructure && terraform output -raw vault_url)
export VAULT_TOKEN=$(cat unseal.json | jq -r '.root_token')
export VAULT_SKIP_VERIFY=true
export MSSQL_CLI_USER=boundary
export MSSQL_CLI_PASSWORD=$(cd infrastructure && terraform output -raw mssql_password)