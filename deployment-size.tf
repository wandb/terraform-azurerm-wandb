locals {
  # Specifications for t-shirt sized deployments
  deployment_size = {
    small = {
      db            = "MO_Standard_E2ds_v4",
      node_count    = 2,
      node_instance = "Standard_E4s_v5"
      cache         = "3"
    },
    medium = {
      db            = "MO_Standard_E4ds_v4",
      node_count    = 2,
      node_instance = "Standard_E4s_v5"
      cache         = "3"
    },
    large = {
      db            = "MO_Standard_E8ds_v4",
      node_count    = 3,
      node_instance = "Standard_E8s_v5"
      cache         = "4"
    },
    xlarge = {
      db            = "MO_Standard_E16ds_v4 ",
      node_count    = 3,
      node_instance = "Standard_E8s_v5"
      cache         = "4"
    },
    xxlarge = {
      db            = "MO_Standard_E32ds_v4",
      node_count    = 3,
      node_instance = "Standard_E16s_v5"
      cache         = "5"
    }
  }
}