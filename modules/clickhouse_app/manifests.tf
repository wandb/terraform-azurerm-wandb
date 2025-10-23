# Using kubectl provider for better CRD handling
# This file replaces the kubernetes_manifest resources with kubectl_manifest

resource "kubectl_manifest" "clickhouse_keeper" {
  count = var.deploy_clickhouse_objects ? 1 : 0
  yaml_body = yamlencode({
    apiVersion = "clickhouse-keeper.altinity.com/v1"
    kind       = "ClickHouseKeeperInstallation"
    metadata = {
      name        = local.keeper_name
      namespace   = var.namespace
      annotations = {}
    }
    spec = {
      defaults = {
        templates = {
          podTemplate             = "default"
          dataVolumeClaimTemplate = "default"
        }
      }
      templates = {
        podTemplates = [{
          name = "keeper"
          metadata = {
            annotations = {}
            labels = {
              app = "clickhouse-keeper"
            }
          }
          spec = {
            affinity = {
              podAntiAffinity = {
                requiredDuringSchedulingIgnoredDuringExecution = [{
                  labelSelector = {
                    matchExpressions = [{
                      key      = "app"
                      operator = "In"
                      values   = ["clickhouse-keeper"]
                    }]
                  }
                  topologyKey = "kubernetes.io/hostname"
                }]
              }
            }
            containers = [{
              name            = "clickhouse-keeper"
              imagePullPolicy = "IfNotPresent"
              image           = var.keeper_image
              resources = {
                requests = {
                  memory = var.keeper_memory_request
                  cpu    = var.keeper_cpu_request
                }
                limits = {
                  memory = var.keeper_memory_limit
                  cpu    = var.keeper_cpu_limit
                }
              }
            }]
          }
        }]
        volumeClaimTemplates = [{
          name = "data"
          metadata = {
            labels = {
              app = "clickhouse-keeper"
            }
          }
          spec = {
            storageClassName = local.keeper_volume_storage_class
            accessModes      = ["ReadWriteOnce"]
            resources = {
              requests = {
                storage = local.keeper_volume_size
              }
            }
          }
        }]
      }
      configuration = {
        clusters = [{
          name = "keeper"
          layout = {
            replicasCount = var.clickhouse_replicas
          }
          templates = {
            podTemplate             = "keeper"
            dataVolumeClaimTemplate = "data"
          }
        }]
        settings = {
          "logger/level"                                         = "information"
          "logger/console"                                       = "true"
          "listen_host"                                          = "0.0.0.0"
          "keeper_server/four_letter_word_white_list"            = "*"
          "keeper_server/coordination_settings/raft_logs_level" = "information"
        }
      }
    }
  })

  depends_on = [time_sleep.wait_for_crds]
}

resource "kubectl_manifest" "clickhouse_installation" {
  count = var.deploy_clickhouse_objects ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "clickhouse.altinity.com/v1"
    kind       = "ClickHouseInstallation"
    metadata = {
      name        = local.installation_name
      namespace   = var.namespace
      annotations = {}
    }
    spec = {
      defaults = {
        templates = {
          podTemplate             = "clickhouse"
          dataVolumeClaimTemplate = "data"
        }
      }
      templates = {
        podTemplates = [{
          name = "clickhouse"
          metadata = {
            annotations = {}
            labels = {
              app                           = "clickhouse-server"
              "azure.workload.identity/use" = "true"
            }
          }
          spec = {
            serviceAccountName = kubernetes_service_account.clickhouse.metadata[0].name
            affinity = {
              podAntiAffinity = {
                requiredDuringSchedulingIgnoredDuringExecution = [{
                  labelSelector = {
                    matchExpressions = [{
                      key      = "app"
                      operator = "In"
                      values   = ["clickhouse-server"]
                    }]
                  }
                  topologyKey = "kubernetes.io/hostname"
                }]
              }
            }
            containers = [{
              name  = "clickhouse"
              image = var.clickhouse_image
              resources = {
                requests = {
                  memory = var.clickhouse_memory_request
                  cpu    = var.clickhouse_cpu_request
                }
                limits = {
                  memory = var.clickhouse_memory_limit
                  cpu    = var.clickhouse_cpu_limit
                }
              }
            }]
          }
        }]
        volumeClaimTemplates = [
          {
            name = "data"
            metadata = {
              labels = {
                app = "clickhouse-server"
              }
            }
            spec = {
              accessModes      = ["ReadWriteOnce"]
              storageClassName = var.storage_class_data
              resources = {
                requests = {
                  storage = local.data_volume_size
                }
              }
            }
          },
          {
            name = "logs"
            metadata = {
              labels = {
                app = "clickhouse-server"
              }
            }
            spec = {
              accessModes      = ["ReadWriteOnce"]
              storageClassName = var.storage_class_logs
              resources = {
                requests = {
                  storage = local.log_volume_size
                }
              }
            }
          }
        ]
      }
      configuration = {
        zookeeper = {
          nodes = [
            for i in range(var.clickhouse_replicas) : {
              host = "chk-${local.keeper_name}-keeper-0-${i}.${var.namespace}.svc.cluster.local"
              port = 2181
            }
          ]
        }
        users = {
          "weave/password" = {
            valueFrom = {
              secretKeyRef = {
                name = kubernetes_secret.ch_db.metadata[0].name
                key  = "password"
              }
            }
          }
          "weave/access_management" = 1
          "weave/profile"            = "default"
          "weave/networks/ip"        = ["0.0.0.0/0"]
        }
        settings = {}
        clusters = [{
          name = local.cluster_name
          layout = {
            shardsCount   = 1
            replicasCount = var.clickhouse_replicas
          }
          templates = {
            podTemplate             = "clickhouse"
            dataVolumeClaimTemplate = "data"
            logVolumeClaimTemplate  = "logs"
          }
        }]
        files = {
          "config.d/network_configuration.xml" = <<-XML
            <clickhouse>
                <network_configuration>
                    <listen_host>0.0.0.0</listen_host>
                    <listen_host>::</listen_host>
                </network_configuration>
            </clickhouse>
          XML
          "config.d/logger.xml" = <<-XML
            <clickhouse>
                <logger>
                    <level>information</level>
                </logger>
            </clickhouse>
          XML
          "config.d/remote_servers.xml" = <<-XML
            <clickhouse>
              <remote_servers>
                <weave_cluster>
                  <shard>
                    ${join("", [for i in range(var.clickhouse_replicas) : <<-REPLICA
                    <replica>
                      <host>chi-${local.installation_name}-${local.cluster_name}-0-${i}.${var.namespace}.svc.cluster.local</host>
                      <port>9000</port>
                    </replica>
                    REPLICA
                    ])}
                  </shard>
                </weave_cluster>
              </remote_servers>
            </clickhouse>
          XML
          "config.d/storage_configuration.xml" = <<-XML
            <clickhouse>
                <storage_configuration>
                    <disks>
                        <azure_disk>
                            <type>azure_blob_storage</type>
                            <storage_account_url>${local.storage_account_url}</storage_account_url>
                            <container_name>${var.storage_container_name}</container_name>
                            <use_workload_identity>true</use_workload_identity>
                            <metadata_path>/var/lib/clickhouse/disks/azure_disk/</metadata_path>
                            <max_single_part_upload_size>104857600</max_single_part_upload_size>
                        </azure_disk>
                        <azure_disk_cache>
                            <type>cache</type>
                            <disk>azure_disk</disk>
                            <path>/var/lib/clickhouse/azure_disk_cache/cache/</path>
                            <max_size>${local.cache_size}</max_size>
                            <cache_on_write_operations>true</cache_on_write_operations>
                        </azure_disk_cache>
                    </disks>
                    <policies>
                        <azure_main>
                            <volumes>
                                <main>
                                    <disk>azure_disk_cache</disk>
                                </main>
                            </volumes>
                        </azure_main>
                    </policies>
                </storage_configuration>
                <merge_tree>
                    <storage_policy>azure_main</storage_policy>
                </merge_tree>
            </clickhouse>
          XML
        }
      }
    }
  })

  depends_on = [
    kubectl_manifest.clickhouse_keeper,
    kubernetes_service_account.clickhouse,
    kubernetes_secret.ch_db
  ]
}
