#!/bin/bash

export BOUNDARY_ADDR=$(cd infrastructure && terraform output -raw boundary_url)
export BOUNDARY_TLS_INSECURE=true

set -v

boundary authenticate password \
    -auth-method-id=$(cd boundary && terraform output -raw password_auth_method_id) \
    -login-name=boundary-admin \
    -password=$(cd boundary && terraform output -raw admin_password)