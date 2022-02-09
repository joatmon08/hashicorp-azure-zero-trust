#!/bin/bash

set -v

sqlcmd -S "127.0.0.1" -C \
    -U boundary@$(cd infrastructure && terraform output -raw mssql_server_name) \
	-P $(cd infrastructure && terraform output -raw mssql_password) \
    -d DemoExpenses \
    -i database/setup.sql