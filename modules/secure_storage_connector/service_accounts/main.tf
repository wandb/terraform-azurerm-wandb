locals {
  k8s_sa_map = {
    api                  = "wandb-api",
    console              = "wandb-console",
    executor             = "wandb-executor",
    parquet              = "wandb-parquet",
    filestream           = "wandb-filestream",
    filemeta             = "wandb-filemeta",
    glue                 = "wandb-glue",
    weave                = "wandb-weave",
    weaveTrace           = "wandb-weave-trace",
    settingsMigrationJob = "wandb-settings-migration-job",
    bufstream            = "bufstream-service-account",
    bucket-access        = "wandb-bucket-access"
    # "flatRunFieldsUpdater" = "wandb-flat-run-fields-updater",
  }
}

output "k8s_sa_map" {
  value = local.k8s_sa_map
}
