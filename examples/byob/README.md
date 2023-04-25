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