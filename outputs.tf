# =============================================================================
# Bastion Host Outputs
# =============================================================================

output "id" {
  value       = azurerm_bastion_host.this.id
  description = "The resource ID of the Azure Bastion Host"
}

output "name" {
  value       = azurerm_bastion_host.this.name
  description = "The name of the Azure Bastion Host"
}

output "dns_name" {
  value       = azurerm_bastion_host.this.dns_name
  description = "The FQDN for the Azure Bastion Host"
}

output "sku" {
  value       = azurerm_bastion_host.this.sku
  description = "The SKU of the Azure Bastion Host (Basic or Standard)"
}

output "scale_units" {
  value       = azurerm_bastion_host.this.scale_units
  description = "The number of scale units provisioned for the Azure Bastion Host"
}

# =============================================================================
# Subnet Outputs
# =============================================================================

output "subnet_id" {
  value       = var.create_subnet ? azurerm_subnet.bastion[0].id : data.azurerm_subnet.existing[0].id
  description = "The resource ID of the AzureBastionSubnet"
}

output "subnet_name" {
  value       = "AzureBastionSubnet"
  description = "The name of the AzureBastionSubnet (always 'AzureBastionSubnet' per Azure requirements)"
}

output "subnet_address_prefix" {
  value       = var.create_subnet ? azurerm_subnet.bastion[0].address_prefixes[0] : data.azurerm_subnet.existing[0].address_prefixes[0]
  description = "The address prefix of the AzureBastionSubnet"
}

# =============================================================================
# Public IP Outputs
# =============================================================================

output "public_ip_id" {
  value       = var.create_public_ip ? azurerm_public_ip.bastion[0].id : data.azurerm_public_ip.existing[0].id
  description = "The resource ID of the Public IP address"
}

output "public_ip_address" {
  value       = var.create_public_ip ? azurerm_public_ip.bastion[0].ip_address : data.azurerm_public_ip.existing[0].ip_address
  description = "The IP address value that was allocated for the Azure Bastion Host"
}

output "public_ip_name" {
  value       = var.create_public_ip ? azurerm_public_ip.bastion[0].name : data.azurerm_public_ip.existing[0].name
  description = "The name of the Public IP address"
}

# =============================================================================
# Configuration Outputs
# =============================================================================

output "location" {
  value       = azurerm_bastion_host.this.location
  description = "The Azure region where the Bastion Host is deployed"
}

output "resource_group_name" {
  value       = azurerm_bastion_host.this.resource_group_name
  description = "The resource group name where the Bastion Host is deployed"
}

output "virtual_network_name" {
  value       = var.virtual_network_name
  description = "The virtual network name where the Bastion Host is deployed"
}

# =============================================================================
# Feature Flags Outputs
# =============================================================================

output "copy_paste_enabled" {
  value       = azurerm_bastion_host.this.copy_paste_enabled
  description = "Whether copy/paste functionality is enabled"
}

output "file_copy_enabled" {
  value       = azurerm_bastion_host.this.file_copy_enabled
  description = "Whether file transfer functionality is enabled (Standard SKU only)"
}

output "tunneling_enabled" {
  value       = azurerm_bastion_host.this.tunneling_enabled
  description = "Whether native client support (tunneling) is enabled (Standard SKU only)"
}

output "shareable_link_enabled" {
  value       = azurerm_bastion_host.this.shareable_link_enabled
  description = "Whether shareable link functionality is enabled (Standard SKU only)"
}

output "ip_connect_enabled" {
  value       = azurerm_bastion_host.this.ip_connect_enabled
  description = "Whether IP-based connections are enabled (Standard SKU only)"
}

# =============================================================================
# Tagging Outputs
# =============================================================================

output "tags" {
  value       = azurerm_bastion_host.this.tags
  description = "The tags applied to the Azure Bastion Host"
}

# =============================================================================
# Diagnostics Outputs
# =============================================================================

output "diagnostics_enabled" {
  value       = var.enable_diagnostics
  description = "Whether diagnostics are enabled for the Azure Bastion Host"
}
