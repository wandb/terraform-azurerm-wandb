# Azure BYOB

This example can be used to create the Azure Blob Ctorage container required when using the BYOB mode for Dedicated Cloud deployment.

1. Make sure you have Terraform installed
2. Make sure you have Azure CLI installed and configured
3. Clone this repository
4. Access the directory `examples/byob` and fix the options in the file `terraform.tfvars`

Once the configuration is done, just execute the Terraform following the example below

```bash
terraform init
terraform apply -var-file=terraform.tfvars
```

At the end of execution you will have the following output

```bash
blob_container = "rgnamestorage/wandb"
storage_key = <sensitive>
```

To retrieve the storage key, you can use the Azure CLI installed previously like the example below.

```basb
az storage account keys list --account-name byobflamastorage --query '[].{key: value}' --output tsv
```

You only need to provide one key.

* Note that all information about Storage Account and keys are mere examples, they are not valid.