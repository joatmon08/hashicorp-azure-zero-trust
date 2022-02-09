#!/bin/bash

export VAULT_ADDR=$(cd infrastructure && terraform output -raw vault_url)
export VAULT_SKIP_VERIFY=true

vault operator init -key-shares=1 -key-threshold=1 -format=json > unseal.json
vault operator unseal