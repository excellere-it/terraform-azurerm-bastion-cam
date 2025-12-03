# =============================================================================
# Module: Azure Bastion
# =============================================================================
#
# Purpose:
#   This module provisions Azure Bastion Host for secure RDP/SSH connectivity
#   to virtual machines without exposing public IP addresses. Azure Bastion
#   provides fully managed PaaS connectivity directly from the Azure portal.
#
# Features:
#   - Azure Bastion Host with Basic and Standard SKU support
#   - Flexible subnet management (create new or use existing AzureBastionSubnet)
#   - Flexible Public IP management (create new or use existing)
#   - Standard SKU advanced features:
#     * Scaling units (2-50 host instances)
#     * File transfer support (upload/download files)
#     * Native client support (connect via native RDP/SSH clients)
#     * Shareable links (temporary access without Azure portal)
#     * IP-based connections (connect to VMs by IP address)
#   - Diagnostics integration with terraform-azurerm-diagnostics
#   - Consistent naming and tagging via terraform-namer
#
# Resources Created:
#   - azurerm_bastion_host (required)
#   - azurerm_public_ip (optional, if create_public_ip = true)
#   - azurerm_subnet (optional, if create_subnet = true)
#
# Dependencies:
#   - terraform-terraform-namer (required)
#   - terraform-azurerm-diagnostics (optional, for logging)
#
# Usage:
#   module "bastion" {
#     source = "path/to/terraform-azurerm-bastion"
#
#     contact     = "ops@company.com"
#     environment = "prd"
#     location    = "centralus"
#     repository  = "terraform-azurerm-bastion"
#     workload    = "bastion"
#
#     resource_group_name = "rg-network-cu-prd-kmi-0"
#     virtual_network_name = "vnet-hub-cu-prd-kmi-0"
#
#     # Subnet configuration
#     create_subnet = true
#     subnet_address_prefix = "10.0.255.0/26"
#
#     # Public IP configuration
#     create_public_ip = true
#
#     # Bastion configuration
#     sku = "Standard"
#     scale_units = 2
#
#     # Standard SKU features
#     file_copy_enabled     = true
#     tunneling_enabled     = true
#     shareable_link_enabled = false
#     ip_connect_enabled    = true
#   }
#
# =============================================================================

# =============================================================================
# Section: Naming and Tagging
# =============================================================================

module "naming" {
  source  = "app.terraform.io/cardi/namer-cam/terraform"

  contact     = var.contact
  environment = var.environment
  location    = var.location
  repository  = var.repository
  workload    = var.workload

  # Note: Not using resource_type since bastionHosts is not in terraform-namer abbreviations
  # Will manually add "bas-" prefix to resource names
}

# =============================================================================
# Section: Data Sources
# =============================================================================

# Get existing subnet if not creating new one
data "azurerm_subnet" "existing" {
  count = var.create_subnet ? 0 : 1

  name                 = "AzureBastionSubnet"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group_name != null ? var.virtual_network_resource_group_name : var.resource_group_name
}

# Get existing public IP if not creating new one
data "azurerm_public_ip" "existing" {
  count = var.create_public_ip ? 0 : 1

  name                = var.existing_public_ip_name
  resource_group_name = var.existing_public_ip_resource_group_name != null ? var.existing_public_ip_resource_group_name : var.resource_group_name
}

# =============================================================================
# Section: Subnet Resources
# =============================================================================

# Create AzureBastionSubnet if requested
resource "azurerm_subnet" "bastion" {
  count = var.create_subnet ? 1 : 0

  name                 = "AzureBastionSubnet" # Azure requires this exact name
  resource_group_name  = var.virtual_network_resource_group_name != null ? var.virtual_network_resource_group_name : var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.subnet_address_prefix]

  # Service endpoints for Azure Bastion (optional)
  service_endpoints = var.subnet_service_endpoints
}

# =============================================================================
# Section: Public IP Resources
# =============================================================================

# Create Standard Public IP for Azure Bastion
resource "azurerm_public_ip" "bastion" {
  count = var.create_public_ip ? 1 : 0

  name                = "pip-${module.naming.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"   # Required for Bastion
  sku                 = "Standard" # Required for Bastion
  zones               = var.public_ip_zones

  tags = module.naming.tags
}

# =============================================================================
# Section: Azure Bastion Host
# =============================================================================

resource "azurerm_bastion_host" "this" {
  name                = "bas-${module.naming.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  scale_units         = var.sku == "Standard" ? var.scale_units : null

  # Standard SKU features
  copy_paste_enabled     = var.copy_paste_enabled
  file_copy_enabled      = var.sku == "Standard" ? var.file_copy_enabled : null
  tunneling_enabled      = var.sku == "Standard" ? var.tunneling_enabled : null
  shareable_link_enabled = var.sku == "Standard" ? var.shareable_link_enabled : null
  ip_connect_enabled     = var.sku == "Standard" ? var.ip_connect_enabled : null

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = var.create_subnet ? azurerm_subnet.bastion[0].id : data.azurerm_subnet.existing[0].id
    public_ip_address_id = var.create_public_ip ? azurerm_public_ip.bastion[0].id : data.azurerm_public_ip.existing[0].id
  }

  tags = module.naming.tags
}

# =============================================================================
# Section: Diagnostics Integration
# =============================================================================

# Integrate with diagnostics module for activity logs
module "diagnostics" {
  count  = var.enable_diagnostics ? 1 : 0
  source  = "app.terraform.io/cardi/diagnostics-cam/azurerm"

  log_analytics_workspace_id = var.log_analytics_workspace_id

  monitored_services = {
    "bastion" = {
      id      = azurerm_bastion_host.this.id
      table   = var.log_analytics_destination_type
      include = ["BastionAuditLogs", "AllMetrics"]
    }
  }
}
