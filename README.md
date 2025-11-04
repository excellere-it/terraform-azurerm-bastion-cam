# Terraform Azure Bastion Module

Production-grade Terraform module for managing Azure Bastion Host - secure RDP/SSH connectivity to virtual machines without exposing public IP addresses.

## Features

- **Dual SKU Support**: Basic and Standard SKUs with all features
- **Flexible Subnet Management**: Create new or use existing AzureBastionSubnet
- **Flexible Public IP**: Create new or use existing Standard Public IP
- **Standard SKU Advanced Features**:
  - Scaling units (2-50 host instances for high availability)
  - File transfer (upload/download files during sessions)
  - Native client support (connect via native RDP/SSH clients)
  - Shareable links (temporary access without Azure portal)
  - IP-based connections (connect to VMs by private IP)
- **Diagnostics Integration**: Built-in support for Log Analytics
- **Consistent Naming and Tagging**: terraform-namer integration
- **Comprehensive Validation**: Input validation for all variables
- **Full Test Coverage**: Native Terraform tests

## Quick Start - Basic SKU

```hcl
module "bastion_basic" {
  source = "path/to/terraform-azurerm-bastion"

  # Required: terraform-namer inputs
  contact     = "ops@company.com"
  environment = "dev"
  location    = "centralus"
  repository  = "terraform-azurerm-bastion"
  workload    = "bastion"

  # Required: resource configuration
  resource_group_name  = "rg-network-cu-dev-kmi-0"
  virtual_network_name = "vnet-hub-cu-dev-kmi-0"

  # Subnet configuration (module creates AzureBastionSubnet)
  create_subnet         = true
  subnet_address_prefix = "10.0.255.0/26"

  # Public IP configuration (module creates Public IP)
  create_public_ip = true

  # Basic SKU (default)
  sku = "Basic"
}
```

## Quick Start - Standard SKU with All Features

```hcl
module "bastion_standard" {
  source = "path/to/terraform-azurerm-bastion"

  # Required: terraform-namer inputs
  contact     = "ops@company.com"
  environment = "prd"
  location    = "centralus"
  repository  = "terraform-azurerm-bastion"
  workload    = "bastion"

  # Required: resource configuration
  resource_group_name  = "rg-network-cu-prd-kmi-0"
  virtual_network_name = "vnet-hub-cu-prd-kmi-0"

  # Use existing subnet and Public IP
  create_subnet            = false
  create_public_ip         = false
  existing_public_ip_name  = "pip-bastion-cu-prd-kmi-0"

  # Standard SKU with scaling
  sku         = "Standard"
  scale_units = 4

  # Enable all Standard SKU features
  file_copy_enabled      = true
  tunneling_enabled      = true
  shareable_link_enabled = false  # Consider security implications
  ip_connect_enabled     = true

  # Enable diagnostics
  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/.../workspaces/law-ops-cu-prd-kmi-0"
}
```

## Azure Bastion Requirements

Azure Bastion has specific requirements that this module handles:

1. **Subnet Name**: Must be exactly `AzureBastionSubnet` (Azure requirement)
2. **Subnet Size**: Minimum /26 CIDR prefix (64 IP addresses)
3. **Public IP**: Must be Standard SKU with Static allocation
4. **Network Security Group**: Not required on AzureBastionSubnet (Azure manages security)

## Architecture

```
┌─────────────────────────────────────────────────┐
│ Azure Virtual Network                            │
│                                                  │
│  ┌─────────────────────────────────────────┐    │
│  │ AzureBastionSubnet (/26 minimum)        │    │
│  │                                          │    │
│  │  ┌──────────────────────────────────┐   │    │
│  │  │ Azure Bastion Host               │   │    │
│  │  │ • SKU: Basic/Standard            │   │    │
│  │  │ • Scale Units: 2-50 (Standard)   │   │    │
│  │  │ • Standard Public IP (Static)    │◄──┼────┼──── Internet
│  │  └──────────────────────────────────┘   │    │
│  └─────────────────────────────────────────┘    │
│                                                  │
│  ┌─────────────────────────────────────────┐    │
│  │ VM Subnet                                │    │
│  │                                          │    │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐ │    │
│  │  │   VM1   │  │   VM2   │  │   VM3   │ │    │
│  │  │ (no PIP)│  │ (no PIP)│  │ (no PIP)│ │    │
│  │  └─────────┘  └─────────┘  └─────────┘ │    │
│  └─────────────────────────────────────────┘    │
│                                                  │
└─────────────────────────────────────────────────┘
```

<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
# =============================================================================
# Example: Basic Azure Bastion Configuration
# =============================================================================
#
# This example demonstrates the simplest Azure Bastion deployment using the
# Basic SKU with automatic subnet and Public IP creation.
#
# Use case: Development environments or simple connectivity needs
#

module "bastion_basic" {
  source = "../.."

  # Required: terraform-namer inputs
  contact     = "ops@example.com"
  environment = "dev"
  location    = "centralus"
  repository  = "terraform-azurerm-bastion"
  workload    = "bastion"

  # Required: resource configuration
  resource_group_name  = "rg-network-cu-dev-kmi-0"
  virtual_network_name = "vnet-hub-cu-dev-kmi-0"

  # Subnet configuration (module creates AzureBastionSubnet)
  create_subnet         = true
  subnet_address_prefix = "10.0.255.0/26" # /26 = 64 IP addresses (Azure minimum)

  # Public IP configuration (module creates Standard Public IP)
  create_public_ip = true

  # Basic SKU configuration
  sku                = "Basic"
  copy_paste_enabled = true # Enable copy/paste (default: true)
}

# =============================================================================
# Outputs
# =============================================================================

output "bastion_id" {
  value       = module.bastion_basic.id
  description = "The resource ID of the Azure Bastion Host"
}

output "bastion_dns_name" {
  value       = module.bastion_basic.dns_name
  description = "The FQDN for accessing the Azure Bastion Host"
}

output "public_ip_address" {
  value       = module.bastion_basic.public_ip_address
  description = "The public IP address allocated to the Bastion Host"
}

output "subnet_id" {
  value       = module.bastion_basic.subnet_id
  description = "The resource ID of the AzureBastionSubnet"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_diagnostics"></a> [diagnostics](#module\_diagnostics) | ../terraform-azurerm-diagnostics | n/a |
| <a name="module_naming"></a> [naming](#module\_naming) | ../terraform-terraform-namer | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_bastion_host.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_public_ip.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_subnet.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_public_ip.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |
| [azurerm_subnet.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_contact"></a> [contact](#input\_contact) | Contact email for resource ownership and notifications | `string` | n/a | yes |
| <a name="input_copy_paste_enabled"></a> [copy\_paste\_enabled](#input\_copy\_paste\_enabled) | Enable copy/paste functionality for connections through the Azure Bastion Host | `bool` | `true` | no |
| <a name="input_create_public_ip"></a> [create\_public\_ip](#input\_create\_public\_ip) | Whether to create a new Standard Public IP for Azure Bastion. If false, existing\_public\_ip\_name must be provided | `bool` | `true` | no |
| <a name="input_create_subnet"></a> [create\_subnet](#input\_create\_subnet) | Whether to create a new AzureBastionSubnet. If false, an existing AzureBastionSubnet must exist in the specified virtual network | `bool` | `true` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Enable diagnostic settings for Azure Bastion Host using the terraform-azurerm-diagnostics module | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, stg, prd, etc.) | `string` | n/a | yes |
| <a name="input_existing_public_ip_name"></a> [existing\_public\_ip\_name](#input\_existing\_public\_ip\_name) | The name of an existing Standard SKU Public IP to use. Only used if create\_public\_ip is false | `string` | `null` | no |
| <a name="input_existing_public_ip_resource_group_name"></a> [existing\_public\_ip\_resource\_group\_name](#input\_existing\_public\_ip\_resource\_group\_name) | The resource group name of the existing Public IP. Defaults to resource\_group\_name if not specified | `string` | `null` | no |
| <a name="input_file_copy_enabled"></a> [file\_copy\_enabled](#input\_file\_copy\_enabled) | Enable file transfer functionality. Only available with Standard SKU | `bool` | `false` | no |
| <a name="input_ip_connect_enabled"></a> [ip\_connect\_enabled](#input\_ip\_connect\_enabled) | Enable IP-based connections. Only available with Standard SKU. Allows connecting to VMs by private IP address | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where resources will be deployed | `string` | n/a | yes |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | The destination type for Log Analytics. Valid values: 'Dedicated', 'AzureDiagnostics'. This controls the table format in Log Analytics | `string` | `"Dedicated"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The resource ID of the Log Analytics workspace for diagnostics. Required if enable\_diagnostics is true | `string` | `null` | no |
| <a name="input_public_ip_zones"></a> [public\_ip\_zones](#input\_public\_ip\_zones) | Availability zones for the Public IP address. Example: ['1', '2', '3'] | `list(string)` | `null` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Source repository name for tracking and documentation | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Azure Bastion Host | `string` | n/a | yes |
| <a name="input_scale_units"></a> [scale\_units](#input\_scale\_units) | The number of scale units for the Azure Bastion Host. Only applicable for Standard SKU. Valid range: 2-50 | `number` | `2` | no |
| <a name="input_shareable_link_enabled"></a> [shareable\_link\_enabled](#input\_shareable\_link\_enabled) | Enable shareable link functionality. Only available with Standard SKU. Allows temporary access without Azure portal | `bool` | `false` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the Azure Bastion Host. Valid values: 'Basic', 'Standard'. Standard SKU enables advanced features like file transfer and native client support | `string` | `"Basic"` | no |
| <a name="input_subnet_address_prefix"></a> [subnet\_address\_prefix](#input\_subnet\_address\_prefix) | The address prefix for the AzureBastionSubnet. Must be /26 or larger. Only used if create\_subnet is true | `string` | `null` | no |
| <a name="input_subnet_service_endpoints"></a> [subnet\_service\_endpoints](#input\_subnet\_service\_endpoints) | Service endpoints to enable on the AzureBastionSubnet. Common values: 'Microsoft.Storage', 'Microsoft.KeyVault' | `list(string)` | `[]` | no |
| <a name="input_tunneling_enabled"></a> [tunneling\_enabled](#input\_tunneling\_enabled) | Enable native client support (tunneling). Only available with Standard SKU. Allows connections via native RDP/SSH clients | `bool` | `false` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network where AzureBastionSubnet exists or will be created | `string` | n/a | yes |
| <a name="input_virtual_network_resource_group_name"></a> [virtual\_network\_resource\_group\_name](#input\_virtual\_network\_resource\_group\_name) | The resource group name of the virtual network. Defaults to resource\_group\_name if not specified | `string` | `null` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload or application name for resource identification | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_copy_paste_enabled"></a> [copy\_paste\_enabled](#output\_copy\_paste\_enabled) | Whether copy/paste functionality is enabled |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Whether diagnostics are enabled for the Azure Bastion Host |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | The FQDN for the Azure Bastion Host |
| <a name="output_file_copy_enabled"></a> [file\_copy\_enabled](#output\_file\_copy\_enabled) | Whether file transfer functionality is enabled (Standard SKU only) |
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the Azure Bastion Host |
| <a name="output_ip_connect_enabled"></a> [ip\_connect\_enabled](#output\_ip\_connect\_enabled) | Whether IP-based connections are enabled (Standard SKU only) |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where the Bastion Host is deployed |
| <a name="output_name"></a> [name](#output\_name) | The name of the Azure Bastion Host |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | The IP address value that was allocated for the Azure Bastion Host |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | The resource ID of the Public IP address |
| <a name="output_public_ip_name"></a> [public\_ip\_name](#output\_public\_ip\_name) | The name of the Public IP address |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name where the Bastion Host is deployed |
| <a name="output_scale_units"></a> [scale\_units](#output\_scale\_units) | The number of scale units provisioned for the Azure Bastion Host |
| <a name="output_shareable_link_enabled"></a> [shareable\_link\_enabled](#output\_shareable\_link\_enabled) | Whether shareable link functionality is enabled (Standard SKU only) |
| <a name="output_sku"></a> [sku](#output\_sku) | The SKU of the Azure Bastion Host (Basic or Standard) |
| <a name="output_subnet_address_prefix"></a> [subnet\_address\_prefix](#output\_subnet\_address\_prefix) | The address prefix of the AzureBastionSubnet |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The resource ID of the AzureBastionSubnet |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | The name of the AzureBastionSubnet (always 'AzureBastionSubnet' per Azure requirements) |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to the Azure Bastion Host |
| <a name="output_tunneling_enabled"></a> [tunneling\_enabled](#output\_tunneling\_enabled) | Whether native client support (tunneling) is enabled (Standard SKU only) |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | The virtual network name where the Bastion Host is deployed |
<!-- END_TF_DOCS -->

## Examples

See the `examples/` directory for complete working examples:

- **default**: Basic SKU with subnet creation
- **standard-all-features**: Standard SKU with all advanced features
- **existing-resources**: Using existing subnet and Public IP

## Cost Considerations

Azure Bastion pricing varies by SKU and scale units:

- **Basic SKU**: ~$149/month (suitable for dev/test, < 25 concurrent users)
- **Standard SKU**: ~$156-$3,623/month (2-50 scale units, production workloads)
- **Cost vs Value**: Replaces jump boxes with 89% lower TCO (including maintenance)

See [COST_ANALYSIS.md](COST_ANALYSIS.md) for detailed cost breakdown, environment-specific recommendations, and optimization strategies.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow and contribution guidelines.

## License

Copyright (c) 2024. All rights reserved.
