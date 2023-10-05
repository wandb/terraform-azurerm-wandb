data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "wandb" {
    name = var.resource_group_name
}

