# =============================================================================
# Example: Azure Bastion with Existing Resources
# =============================================================================
#
# This example demonstrates using pre-existing AzureBastionSubnet and
# Public IP resources, useful when integrating with existing network
# infrastructure.
#
# Use case: Adding Bastion to existing hub network with pre-allocated resources
#

module "bastion_existing_resources" {
  source = "../.."

  # Required: terraform-namer inputs
  contact     = "ops@example.com"
  environment = "prd"
  location    = "centralus"
  repository  = "terraform-azurerm-bastion"
  workload    = "bastion"

  # Required: resource configuration
  resource_group_name  = "rg-network-cu-prd-kmi-0"
  virtual_network_name = "vnet-hub-cu-prd-kmi-0"

  # Use existing subnet (AzureBastionSubnet must already exist)
  create_subnet = false

  # Virtual network in different resource group (optional)
  virtual_network_resource_group_name = "rg-network-cu-prd-kmi-0"

  # Use existing Public IP
  create_public_ip        = false
  existing_public_ip_name = "pip-bastion-cu-prd-kmi-0"

  # Public IP in different resource group (optional)
  existing_public_ip_resource_group_name = "rg-network-cu-prd-kmi-0"

  # Standard SKU with moderate scaling
  sku         = "Standard"
  scale_units = 2

  # Enable selected Standard SKU features
  file_copy_enabled  = true
  tunneling_enabled  = true
  ip_connect_enabled = true

  # Enable diagnostics
  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ops-cu-prd-kmi-0/providers/Microsoft.OperationalInsights/workspaces/law-ops-cu-prd-kmi-0"
}

# =============================================================================
# Outputs
# =============================================================================

output "bastion_id" {
  value       = module.bastion_existing_resources.id
  description = "The resource ID of the Azure Bastion Host"
}

output "bastion_name" {
  value       = module.bastion_existing_resources.name
  description = "The name of the Azure Bastion Host"
}

output "bastion_dns_name" {
  value       = module.bastion_existing_resources.dns_name
  description = "The FQDN for accessing the Azure Bastion Host"
}

output "public_ip_address" {
  value       = module.bastion_existing_resources.public_ip_address
  description = "The public IP address (from existing Public IP resource)"
}
