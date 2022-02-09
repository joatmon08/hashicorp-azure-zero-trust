# boundary-azure-zero-trust

## Demo

1. [Dynamic host catalog](https://learn.hashicorp.com/tutorials/boundary/azure-host-catalogs)
   - This configuration automatically discoveres Azure virtual machines with the tag `{"allow": "operator"}`.
1. [OIDC authentication method](https://learn.hashicorp.com/tutorials/boundary/oidc-auth) with Azure Active Directory
1. [Managed Groups](https://learn.hashicorp.com/tutorials/boundary/oidc-idp-groups?in=boundary/configuration)
1. [Vault Credentials Brokering](https://learn.hashicorp.com/tutorials/boundary/vault-cred-brokering-quickstart?in=boundary/configuration)
   - [MSSQL Database Secrets Engine for Vault](https://www.vaultproject.io/docs/secrets/databases/mssql)

## Usage

### Set up infrastructure

1. Go to the `infrastructure/` directory.

1. Define variables under `infrastructure/variables.tf`.

1. Set Azure credentials in environment variables.

1. Initialize Terraform.
   ```shell
   terraform init
   ```

1. Apply Terraform.
   ```shell
   terraform apply
   ```

1. This creates the following infrastructure:
   1. Boundary cluster (1 controller, 1 worker, PostgreSQL database)
   1. Azure virtual machine
   1. Microsoft SQL Server database
   1. Azure Active Directory group (operators and database administrators)
   1. Azure Active Directory user (operator and database administrator)
   1. Azure Key Vault (for Boundary recovery key)

1. Add permissions to the Boundary OIDC authentication application.
   ```shell
   make ad-admin-consent
   ```


### Set up Boundary

1. Go to the `boundary/` directory.

1. Define variables under `variables.tf.`

1. Initialize Terraform.
   ```shell
   terraform init
   ```

1. Apply Terraform.
   ```shell
   terraform apply
   ```


### Set up Vault

1. Go to the `vault/` directory.

1. Define variables under `variables.tf.`

1. Initialize Terraform.
   ```shell
   terraform init
   ```

1. Apply Terraform.
   ```shell
   terraform apply
   ```

## Access the VM or Database with Boundary

You can authenticate as an administrator using:

```shell
make admin
```

You can authenticate as an operator or database administrator using:

```shell
make operator
```

Either of these commands will return a Boundary token. If you are an operator,
you can access the VM and __read__ from the database.
If you are a database administrator, you can access
the database.

### Virtual Machine SSH Access

This will open a browser window for you to sign on using Azure Active Directory.

SSH to the virtual machine with the following:

```shell
make ssh-vm
```

### Microsoft SQL Server Database Access

#### Administrator

Start the Boundary proxy:

```shell
make boundary-connect-admin
```

This will run the Boundary proxy on port 1433.

Use `sqlcmd` to connect to the database with the proxy:

```shell
bash db.sh
```

##### NOTE

In order to connect to Azure SQL Server via Boundary proxy,
you must specify the server name as part of the user login. If you
want to use Azure AD to log into the database, you _must_ add
the following as a host entry:

```plaintext
# /etc/hosts
127.0.0.1 SERVER.database.windows.net
```

In production, you will want to set up DNS forwarding for the private
IP address of the database.


#### Operator

Start the Boundary proxy:

```shell
make boundary-connect-dev
```

This will run the Boundary proxy on port 1433.

Use `sqlcmd` to connect to the database with the proxy:

```shell
bash db-dev.sh
```