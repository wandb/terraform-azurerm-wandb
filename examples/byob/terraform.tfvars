resource_group_name = "<rg-name>"

location = "<westeurope>"
prefix   = "<byob-wandb>"
tags = {
  "name" = "wandb"
}

#To enable Azure Key Vault encryption uncomment the below lines
# create_cmk = true

# enable_purge_protection       = true
# disable_storage_vault_key_id  = false

# tenant_id = "<tenant_id>"
# client_id = "<client_id>"