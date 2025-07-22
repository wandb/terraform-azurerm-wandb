# Terraform Azure Private Endpoint Module

This Terraform module creates and configures an Azure Private Endpoint with optional networking components, such as a Virtual Network, Subnet, and Private DNS Zone. It supports both creating new resources and referencing existing ones.

## Features
- Configures a Private Endpoint
- Supports Private DNS Zone creation and linking
- Allows referencing existing networking resources
- Uses conditional logic to enable flexible configurations


## Usage Example

```hcl
module "private_endpoint" {
	source                     = "./modules/private_endpoint"
	subscription_id            = "your-subscription-id"
	resource_group_name        = "your-resource-group"
	location                   = "East US"
	create_network             = true
	new_vnet_name              = "my-vnet"
	new_vnet_address_space     = ["10.0.0.0/16"]
	new_subnet_name            = "my-subnet"
	new_subnet_address_prefixes = ["10.0.1.0/24"]
	private_endpoint_name      = "my-private-endpoint"
	private_link_resource_id   = "your-private-link-resource-id"
	private_link_sub_resource_name = "your-sub-resource-name"
	create_private_dns_zone    = true
	private_dns_zone_name      = "privatelink.yourdomain.com"
	dns_name_a_record          = "app-gateway"
	dns_link_name              = "dns-link"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.17 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.17 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_a_record.app_gateway_a_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.private_dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.dns_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_subnet.new_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.new_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_private_dns_zone.existing_private_dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_private_dns_zone_virtual_network_link.existing_dns_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone_virtual_network_link) | data source |
| [azurerm_subnet.private_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_network"></a> [create\_network](#input\_create\_network) | Whether to create a new network and subnet | `bool` | `false` | no |
| <a name="input_create_private_dns_zone"></a> [create\_private\_dns\_zone](#input\_create\_private\_dns\_zone) | Whether to create a new private DNS zone | `bool` | `false` | no |
| <a name="input_dns_link_name"></a> [dns\_link\_name](#input\_dns\_link\_name) | Private DNS link name | `string` | n/a | yes |
| <a name="input_dns_name_a_record"></a> [dns\_name\_a\_record](#input\_dns\_name\_a\_record) | The DNS name for the A record pointing to the Private Endpoint | `string` | n/a | yes |
| <a name="input_existing_private_dns_zone_id"></a> [existing\_private\_dns\_zone\_id](#input\_existing\_private\_dns\_zone\_id) | ID of an existing private DNS zone | `string` | `""` | no |
| <a name="input_existing_private_dns_zone_name"></a> [existing\_private\_dns\_zone\_name](#input\_existing\_private\_dns\_zone\_name) | Name of the existing private DNS zone | `string` | `""` | no |
| <a name="input_existing_subnet_name"></a> [existing\_subnet\_name](#input\_existing\_subnet\_name) | Name of the existing Subnet (if not creating a new one) | `string` | `""` | no |
| <a name="input_existing_vnet_name"></a> [existing\_vnet\_name](#input\_existing\_vnet\_name) | Name of the existing Virtual Network (if not creating a new one) | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_new_subnet_address_prefixes"></a> [new\_subnet\_address\_prefixes](#input\_new\_subnet\_address\_prefixes) | Address prefixes for the new Subnet | `list(string)` | `[]` | no |
| <a name="input_new_subnet_name"></a> [new\_subnet\_name](#input\_new\_subnet\_name) | Name for the new Subnet (if created) | `string` | `""` | no |
| <a name="input_new_vnet_address_space"></a> [new\_vnet\_address\_space](#input\_new\_vnet\_address\_space) | Address space for the new Virtual Network | `list(string)` | `[]` | no |
| <a name="input_new_vnet_name"></a> [new\_vnet\_name](#input\_new\_vnet\_name) | Name for the new Virtual Network (if created) | `string` | `""` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Name of the private DNS zone (if creating a new one) | `string` | `""` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Private Endpoint name | `string` | n/a | yes |
| <a name="input_private_link_resource_id"></a> [private\_link\_resource\_id](#input\_private\_link\_resource\_id) | Resource ID of the Private Link service | `string` | n/a | yes |
| <a name="input_private_link_sub_resource_name"></a> [private\_link\_sub\_resource\_name](#input\_private\_link\_sub\_resource\_name) | Subresource name for Private Link connection | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing resource group name | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure Subscription ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the Private Endpoint |
| <a name="output_private_url"></a> [private\_url](#output\_private\_url) | Full Private URL |


## Applying the Module
To apply the module, run the following Terraform commands:
```sh
terraform plan
terraform apply -auto-approve
```

## Testing the Module
To test the module deployment, follow these steps:
1. Validate the Terraform configuration:
   ```sh
   terraform validate
   ```
2. Apply the configuration and check outputs:
   ```sh
   terraform output
   ```
3. Verify the Private Endpoint in the Azure Portal:
   - Navigate to **Azure Portal** → **Private Link Center** → **Private Endpoints**.
   - Ensure the created Private Endpoint appears with a successful connection.
4. Check DNS resolution:
   ```sh
   nslookup <private_url>
   ```
5. Confirm Private IP connectivity using a Virtual Machine within the VNet:
   ```sh
   ping <private_ip_address>
   ```
