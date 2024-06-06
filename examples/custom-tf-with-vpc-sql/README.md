# Azure custom terraform deployment : an existing VPC & pre-created subnets, connecting to an existing MySQL cluster.

This example can be used to create the Azure Blob Ctorage container required when using the BYOB mode for Dedicated Cloud deployment.

1. Make sure you have Terraform installed
2. Make sure you have Azure CLI installed and configured
3. Clone this repository
4. Access the directory `examples/custom-tf-with-existing-resources` and fix the options in the file `terraform.tfvars`

Once the configuration is done, just execute the Terraform following the example below

```bash
terraform init
terraform apply -var-file=terraform.tfvars
```

At the end of execution you will have the following output

```bash
vpc_name = "test-vpc"
private_subnet = "private-subnet-test"
public_subnet = "public-subnet-test"
database_env = { 
    host          = "**.mysql.database.azure.com"
    username      = "**"
    password      = "**"
    database_name = "**" }

```