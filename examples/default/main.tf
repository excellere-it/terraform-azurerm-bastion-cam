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
