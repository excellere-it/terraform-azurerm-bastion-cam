# =============================================================================
# Example: Standard Azure Bastion with All Features
# =============================================================================
#
# This example demonstrates the full-featured Azure Bastion deployment using
# Standard SKU with all advanced capabilities enabled.
#
# Use case: Production environments requiring:
#   - High availability (scaling units)
#   - File transfer during sessions
#   - Native client connectivity (RDP/SSH clients)
#   - IP-based connections
#   - Comprehensive monitoring
#

module "bastion_standard" {
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

  # Subnet configuration (module creates AzureBastionSubnet)
  create_subnet         = true
  subnet_address_prefix = "10.0.255.0/26"

  # Enable service endpoints for enhanced security
  subnet_service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault"
  ]

  # Public IP configuration (module creates Standard Public IP)
  create_public_ip = true
  public_ip_zones  = ["1", "2", "3"] # Zone-redundant for high availability

  # Standard SKU configuration
  sku         = "Standard"
  scale_units = 4 # 2-50 units, higher = more concurrent sessions

  # Enable all Standard SKU features
  copy_paste_enabled     = true  # Copy/paste between local and remote
  file_copy_enabled      = true  # Upload/download files during sessions
  tunneling_enabled      = true  # Connect via native RDP/SSH clients (az network bastion tunnel)
  ip_connect_enabled     = true  # Connect to VMs by private IP address
  shareable_link_enabled = false # Temporary access links (consider security implications)

  # Enable comprehensive diagnostics
  enable_diagnostics             = true
  log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ops-cu-prd-kmi-0/providers/Microsoft.OperationalInsights/workspaces/law-ops-cu-prd-kmi-0"
  log_analytics_destination_type = "Dedicated"
}

# =============================================================================
# Outputs
# =============================================================================

output "bastion_id" {
  value       = module.bastion_standard.id
  description = "The resource ID of the Azure Bastion Host"
}

output "bastion_dns_name" {
  value       = module.bastion_standard.dns_name
  description = "The FQDN for accessing the Azure Bastion Host"
}

output "public_ip_address" {
  value       = module.bastion_standard.public_ip_address
  description = "The public IP address allocated to the Bastion Host"
}

output "scale_units" {
  value       = module.bastion_standard.scale_units
  description = "The number of scale units provisioned"
}

output "enabled_features" {
  value = {
    copy_paste     = module.bastion_standard.copy_paste_enabled
    file_copy      = module.bastion_standard.file_copy_enabled
    tunneling      = module.bastion_standard.tunneling_enabled
    shareable_link = module.bastion_standard.shareable_link_enabled
    ip_connect     = module.bastion_standard.ip_connect_enabled
    diagnostics    = module.bastion_standard.diagnostics_enabled
  }
  description = "Map of enabled features"
}
