# =============================================================================
# Required Variables
# =============================================================================

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure Bastion Host"

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name cannot be empty"
  }
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network where AzureBastionSubnet exists or will be created"

  validation {
    condition     = length(var.virtual_network_name) > 0
    error_message = "Virtual network name cannot be empty"
  }
}

# =============================================================================
# Bastion Configuration
# =============================================================================

variable "sku" {
  type        = string
  description = "The SKU of the Azure Bastion Host. Valid values: 'Basic', 'Standard'. Standard SKU enables advanced features like file transfer and native client support"
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "SKU must be either 'Basic' or 'Standard'"
  }
}

variable "scale_units" {
  type        = number
  description = "The number of scale units for the Azure Bastion Host. Only applicable for Standard SKU. Valid range: 2-50"
  default     = 2

  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50
    error_message = "Scale units must be between 2 and 50"
  }
}

variable "copy_paste_enabled" {
  type        = bool
  description = "Enable copy/paste functionality for connections through the Azure Bastion Host"
  default     = true
}

variable "file_copy_enabled" {
  type        = bool
  description = "Enable file transfer functionality. Only available with Standard SKU"
  default     = false
}

variable "tunneling_enabled" {
  type        = bool
  description = "Enable native client support (tunneling). Only available with Standard SKU. Allows connections via native RDP/SSH clients"
  default     = false
}

variable "shareable_link_enabled" {
  type        = bool
  description = "Enable shareable link functionality. Only available with Standard SKU. Allows temporary access without Azure portal"
  default     = false
}

variable "ip_connect_enabled" {
  type        = bool
  description = "Enable IP-based connections. Only available with Standard SKU. Allows connecting to VMs by private IP address"
  default     = false
}

# =============================================================================
# Subnet Configuration
# =============================================================================

variable "create_subnet" {
  type        = bool
  description = "Whether to create a new AzureBastionSubnet. If false, an existing AzureBastionSubnet must exist in the specified virtual network"
  default     = true
}

variable "subnet_address_prefix" {
  type        = string
  description = "The address prefix for the AzureBastionSubnet. Must be /26 or larger. Only used if create_subnet is true"
  default     = null

  validation {
    condition = var.subnet_address_prefix == null || (
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_address_prefix)) &&
      tonumber(split("/", var.subnet_address_prefix)[1]) <= 26
    )
    error_message = "Subnet address prefix must be a valid CIDR notation with prefix length of /26 or larger (smaller number)"
  }
}

variable "subnet_service_endpoints" {
  type        = list(string)
  description = "Service endpoints to enable on the AzureBastionSubnet. Common values: 'Microsoft.Storage', 'Microsoft.KeyVault'"
  default     = []
}

variable "virtual_network_resource_group_name" {
  type        = string
  description = "The resource group name of the virtual network. Defaults to resource_group_name if not specified"
  default     = null
}

# =============================================================================
# Public IP Configuration
# =============================================================================

variable "create_public_ip" {
  type        = bool
  description = "Whether to create a new Standard Public IP for Azure Bastion. If false, existing_public_ip_name must be provided"
  default     = true
}

variable "existing_public_ip_name" {
  type        = string
  description = "The name of an existing Standard SKU Public IP to use. Only used if create_public_ip is false"
  default     = null

  validation {
    condition     = var.create_public_ip || (var.existing_public_ip_name != null && length(var.existing_public_ip_name) > 0)
    error_message = "existing_public_ip_name must be provided when create_public_ip is false"
  }
}

variable "existing_public_ip_resource_group_name" {
  type        = string
  description = "The resource group name of the existing Public IP. Defaults to resource_group_name if not specified"
  default     = null
}

variable "public_ip_zones" {
  type        = list(string)
  description = "Availability zones for the Public IP address. Example: ['1', '2', '3']"
  default     = null
}

# =============================================================================
# Diagnostics Configuration
# =============================================================================

variable "enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings for Azure Bastion Host using the terraform-azurerm-diagnostics module"
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The resource ID of the Log Analytics workspace for diagnostics. Required if enable_diagnostics is true"
  default     = null

  validation {
    condition     = !var.enable_diagnostics || (var.log_analytics_workspace_id != null && length(var.log_analytics_workspace_id) > 0)
    error_message = "log_analytics_workspace_id must be provided when enable_diagnostics is true"
  }
}

variable "log_analytics_destination_type" {
  type        = string
  description = "The destination type for Log Analytics. Valid values: 'Dedicated', 'AzureDiagnostics'. This controls the table format in Log Analytics"
  default     = "Dedicated"

  validation {
    condition     = contains(["Dedicated", "AzureDiagnostics"], var.log_analytics_destination_type)
    error_message = "log_analytics_destination_type must be either 'Dedicated' or 'AzureDiagnostics'"
  }
}

# =============================================================================
# Naming Variables (terraform-namer)
# =============================================================================

variable "contact" {
  type        = string
  description = "Contact email for resource ownership and notifications"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.contact))
    error_message = "Contact must be a valid email address"
  }
}

variable "environment" {
  type        = string
  description = "Environment name (dev, stg, prd, etc.)"

  validation {
    condition     = contains(["dev", "stg", "prd", "sbx", "tst", "ops", "hub"], var.environment)
    error_message = "Environment must be one of: dev, stg, prd, sbx, tst, ops, hub"
  }
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed"

  validation {
    condition = contains([
      "centralus", "eastus", "eastus2", "westus", "westus2", "westus3",
      "northcentralus", "southcentralus", "westcentralus",
      "canadacentral", "canadaeast",
      "brazilsouth",
      "northeurope", "westeurope",
      "uksouth", "ukwest",
      "francecentral", "francesouth",
      "germanywestcentral",
      "switzerlandnorth",
      "norwayeast",
      "eastasia", "southeastasia",
      "japaneast", "japanwest",
      "australiaeast", "australiasoutheast",
      "centralindia", "southindia", "westindia"
    ], var.location)
    error_message = "Location must be a valid Azure region"
  }
}

variable "repository" {
  type        = string
  description = "Source repository name for tracking and documentation"

  validation {
    condition     = length(var.repository) > 0
    error_message = "Repository name cannot be empty"
  }
}

variable "workload" {
  type        = string
  description = "Workload or application name for resource identification"

  validation {
    condition     = length(var.workload) > 0 && length(var.workload) <= 20
    error_message = "Workload name must be 1-20 characters"
  }
}
