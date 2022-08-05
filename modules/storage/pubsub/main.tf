resource "azurerm_storage_queue" "default" {
  name                 = "wandb-file-metadata"
  storage_account_name = var.storage_account.name
}

resource "azurerm_eventgrid_system_topic" "default" {
  name                   = "wandb-file-metadata-topic"
  location               = var.location
  resource_group_name    = var.resource_group_name
  source_arm_resource_id = var.storage_account.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "default" {
  name = "wandb-file-metadata-subscription"
  # scope                = azurerm_resource_group.wandb.id
  system_topic         = azurerm_eventgrid_system_topic.default.name
  resource_group_name  = var.storage_account.name
  included_event_types = ["Microsoft.Storage.BlobCreated"]

  subject_filter {
    subject_begins_with = "/blobServices/default/containers/${var.storage_container.name}/blobs/"
  }

  storage_queue_endpoint {
    storage_account_id = var.storage_account.id
    queue_name         = azurerm_storage_queue.default.name
  }
}