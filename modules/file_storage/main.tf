data "azurerm_resource_group" "wandb" {
    name  = "${var.namespace}"
}

resource "azurerm_storage_account" "wandb" {
  name                     = replace("${var.namespace}-storage","-","")
  resource_group_name      = data.azurerm_resource_group.wandb.name
  location                 = data.azurerm_resource_group.wandb.location
  account_tier             = "Standard"
  account_replication_type = "LRS" #TODO:Some regions don't support ZRS, change this back to LRS
  min_tls_version          = "TLS1_2"

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "PUT"]
      allowed_origins    = ["*"]
      exposed_headers    = ["ETag"]
      max_age_in_seconds = 3600
    }
  }
}

resource "azurerm_storage_container" "wandb" {
  name                  = "wandb-files"
  storage_account_name  = azurerm_storage_account.wandb.name
  container_access_type = "private"
}

resource "azurerm_storage_queue" "wandb" {
  name                 = "wandb-file-metadata"
  storage_account_name = azurerm_storage_account.wandb.name
}

resource "azurerm_eventgrid_system_topic" "wandb" {
  name                   = "wandb-file-metadata-topic"
  location               = data.azurerm_resource_group.wandb.location
  resource_group_name    = data.azurerm_resource_group.wandb.name
  source_arm_resource_id = azurerm_storage_account.wandb.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "wandb" {
  name = "wandb-file-metadata-subscription"
  system_topic         = azurerm_eventgrid_system_topic.wandb.name
  resource_group_name  = data.azurerm_resource_group.wandb.name
  included_event_types = ["Microsoft.Storage.BlobCreated"]
  subject_filter {
    subject_begins_with = "/blobServices/default/containers/wandb-files/blobs/"
  }

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.wandb.id
    queue_name         = azurerm_storage_queue.wandb.name
  }
}
