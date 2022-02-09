#!/bin/bash

set -x

## NOTE - make sure you add your database URL to the hosts file!

sqlcmd -S $(cd infrastructure && terraform output -raw mssql_url) -C \
    -G -U $(cd infrastructure && terraform output -raw mssql_admin_username)