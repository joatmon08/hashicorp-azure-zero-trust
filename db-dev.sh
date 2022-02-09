#!/bin/bash

set -v

sqlcmd -S "127.0.0.1" -C \
    -U $(cat db.json | jq -r '.item.credentials[0].secret.decoded.username')@$(cd infrastructure && terraform output -raw mssql_server_name) \
	-P "$(cat db.json | jq -r '.item.credentials[0].secret.decoded.password')" \
    -d DemoExpenses