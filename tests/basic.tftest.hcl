# =============================================================================
# Basic Functionality Tests
# =============================================================================
#
# These tests validate core module functionality using plan-only commands.
# No Azure resources are created, ensuring fast and cost-free execution.
#

# Configure Azure provider for tests
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Test: Default Basic SKU configuration with subnet and Public IP creation
run "test_basic_sku_with_creation" {
  command = plan

  variables {
    # Required terraform-namer inputs
    contact     = "test@example.com"
    environment = "dev"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "test"

    # Required resource configuration
    resource_group_name  = "rg-test-cu-dev-kmi-0"
    virtual_network_name = "vnet-test-cu-dev-kmi-0"

    # Subnet configuration
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"

    # Public IP configuration
    create_public_ip = true

    # Basic SKU
    sku = "Basic"
  }

  # Validate SKU (known at plan time)
  assert {
    condition     = output.sku == "Basic"
    error_message = "SKU must be Basic"
  }

  # Validate subnet name (known at plan time)
  assert {
    condition     = output.subnet_name == "AzureBastionSubnet"
    error_message = "Subnet name must be AzureBastionSubnet"
  }

  # Validate location (known at plan time)
  assert {
    condition     = output.location == "centralus"
    error_message = "Location must match input"
  }

  # Validate copy/paste enabled (known at plan time)
  assert {
    condition     = output.copy_paste_enabled == true
    error_message = "Copy/paste should be enabled by default"
  }
}

# Test: Standard SKU with all features enabled
run "test_standard_sku_all_features" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "prd"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "bastion"

    resource_group_name  = "rg-network-cu-prd-kmi-0"
    virtual_network_name = "vnet-hub-cu-prd-kmi-0"

    create_subnet         = true
    subnet_address_prefix = "10.1.255.0/26"
    create_public_ip      = true

    # Standard SKU configuration
    sku         = "Standard"
    scale_units = 4

    # Enable all Standard features
    file_copy_enabled      = true
    tunneling_enabled      = true
    shareable_link_enabled = true
    ip_connect_enabled     = true
  }

  # All these are known at plan time for Standard SKU
  assert {
    condition     = output.sku == "Standard"
    error_message = "SKU must be Standard"
  }

  assert {
    condition     = output.scale_units == 4
    error_message = "Scale units must be 4"
  }

  assert {
    condition     = output.location == "centralus"
    error_message = "Location must match input"
  }

  assert {
    condition     = output.file_copy_enabled == true
    error_message = "File copy must be enabled"
  }

  assert {
    condition     = output.tunneling_enabled == true
    error_message = "Tunneling (native client) must be enabled"
  }

  assert {
    condition     = output.shareable_link_enabled == true
    error_message = "Shareable link must be enabled"
  }

  assert {
    condition     = output.ip_connect_enabled == true
    error_message = "IP connect must be enabled"
  }
}

# Test: Using existing resources - commented out as it requires real Azure resources
# This would need actual Azure infrastructure for data sources to work
# run "test_existing_resources" { ... }

# Test: Diagnostics integration enabled
run "test_diagnostics_enabled" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "prd"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "bastion"

    resource_group_name  = "rg-network-cu-prd-kmi-0"
    virtual_network_name = "vnet-hub-cu-prd-kmi-0"

    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    sku = "Standard"

    # Enable diagnostics
    enable_diagnostics         = true
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ops/providers/Microsoft.OperationalInsights/workspaces/law-ops"
  }

  assert {
    condition     = output.diagnostics_enabled == true
    error_message = "Diagnostics must be enabled"
  }
}

# Test: Copy/paste enabled by default
run "test_copy_paste_default" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "dev"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "test"

    resource_group_name  = "rg-test-cu-dev-kmi-0"
    virtual_network_name = "vnet-test-cu-dev-kmi-0"

    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true
  }

  assert {
    condition     = output.copy_paste_enabled == true
    error_message = "Copy/paste should be enabled by default"
  }
}

# Test: Naming conventions - commented out as names aren't known at plan time
# These would need to be tested with apply command
# run "test_naming_conventions" { ... }

# Test: Location consistency
run "test_location_consistency" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "dev"
    location    = "eastus2"
    repository  = "terraform-azurerm-bastion"
    workload    = "test"

    resource_group_name  = "rg-test-eu2-dev-kmi-0"
    virtual_network_name = "vnet-test-eu2-dev-kmi-0"

    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true
  }

  assert {
    condition     = output.location == "eastus2"
    error_message = "Output location must match input location"
  }
}

# Test: Standard SKU with minimal scale units
run "test_standard_sku_min_scale" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "dev"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "test"

    resource_group_name  = "rg-test-cu-dev-kmi-0"
    virtual_network_name = "vnet-test-cu-dev-kmi-0"

    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    sku         = "Standard"
    scale_units = 2 # Minimum allowed
  }

  assert {
    condition     = output.sku == "Standard"
    error_message = "SKU must be Standard"
  }

  assert {
    condition     = output.scale_units == 2
    error_message = "Scale units must be 2 (minimum)"
  }
}

# Test: Standard SKU with maximum scale units
run "test_standard_sku_max_scale" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "prd"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "bastion"

    resource_group_name  = "rg-network-cu-prd-kmi-0"
    virtual_network_name = "vnet-hub-cu-prd-kmi-0"

    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    sku         = "Standard"
    scale_units = 50 # Maximum allowed
  }

  assert {
    condition     = output.sku == "Standard"
    error_message = "SKU must be Standard"
  }

  assert {
    condition     = output.scale_units == 50
    error_message = "Scale units must be 50 (maximum)"
  }
}

# Test: Zone redundant Public IP
run "test_zone_redundant_public_ip" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "prd"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "bastion"

    resource_group_name  = "rg-network-cu-prd-kmi-0"
    virtual_network_name = "vnet-hub-cu-prd-kmi-0"

    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true
    public_ip_zones       = ["1", "2", "3"] # Zone-redundant

    sku = "Standard"
  }

  assert {
    condition     = output.sku == "Standard"
    error_message = "Module must support zone-redundant configuration"
  }
}

# Test: Service endpoints on Bastion subnet
run "test_subnet_service_endpoints" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "prd"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "bastion"

    resource_group_name  = "rg-network-cu-prd-kmi-0"
    virtual_network_name = "vnet-hub-cu-prd-kmi-0"

    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    # Enable service endpoints for enhanced security
    subnet_service_endpoints = [
      "Microsoft.Storage",
      "Microsoft.KeyVault"
    ]

    sku = "Basic"
  }

  assert {
    condition     = output.subnet_name == "AzureBastionSubnet"
    error_message = "Subnet must be created with service endpoints"
  }
}

# Test: Standard SKU with selective features
run "test_standard_selective_features" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "prd"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "bastion"

    resource_group_name  = "rg-network-cu-prd-kmi-0"
    virtual_network_name = "vnet-hub-cu-prd-kmi-0"

    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    sku         = "Standard"
    scale_units = 2

    # Enable only specific features for security
    file_copy_enabled      = false # Disabled for security
    tunneling_enabled      = true  # Native client access
    shareable_link_enabled = false # Disabled for security
    ip_connect_enabled     = true  # IP-based connections
  }

  assert {
    condition     = output.file_copy_enabled == false
    error_message = "File copy must be disabled"
  }

  assert {
    condition     = output.tunneling_enabled == true
    error_message = "Tunneling must be enabled"
  }

  assert {
    condition     = output.shareable_link_enabled == false
    error_message = "Shareable link must be disabled for security"
  }

  assert {
    condition     = output.ip_connect_enabled == true
    error_message = "IP connect must be enabled"
  }
}

# Test: Cross-resource-group VNet scenario
run "test_cross_resource_group_vnet" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "prd"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "bastion"

    resource_group_name                 = "rg-bastion-cu-prd-kmi-0"
    virtual_network_name                = "vnet-hub-cu-prd-kmi-0"
    virtual_network_resource_group_name = "rg-network-cu-prd-kmi-0" # Different RG

    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    sku = "Standard"
  }

  assert {
    condition     = output.resource_group_name == "rg-bastion-cu-prd-kmi-0"
    error_message = "Bastion must be in specified resource group"
  }

  assert {
    condition     = output.virtual_network_name == "vnet-hub-cu-prd-kmi-0"
    error_message = "Must reference correct VNet from different RG"
  }
}

# Test: Larger subnet size (/25)
run "test_larger_subnet_size" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "prd"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "bastion"

    resource_group_name  = "rg-network-cu-prd-kmi-0"
    virtual_network_name = "vnet-hub-cu-prd-kmi-0"

    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/25" # Larger than minimum /26
    create_public_ip      = true

    sku = "Standard"
  }

  assert {
    condition     = output.subnet_name == "AzureBastionSubnet"
    error_message = "Must accept larger subnet sizes"
  }
}

# Test: Diagnostics with AzureDiagnostics table type
run "test_diagnostics_azure_diagnostics_table" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "prd"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "bastion"

    resource_group_name  = "rg-network-cu-prd-kmi-0"
    virtual_network_name = "vnet-hub-cu-prd-kmi-0"

    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    sku = "Standard"

    # Enable diagnostics with AzureDiagnostics table
    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ops/providers/Microsoft.OperationalInsights/workspaces/law-ops"
    log_analytics_destination_type = "AzureDiagnostics"
  }

  assert {
    condition     = output.diagnostics_enabled == true
    error_message = "Diagnostics must be enabled"
  }
}

# Test: Basic SKU with copy/paste disabled
run "test_basic_sku_no_copy_paste" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "dev"
    location    = "centralus"
    repository  = "terraform-azurerm-bastion"
    workload    = "test"

    resource_group_name  = "rg-test-cu-dev-kmi-0"
    virtual_network_name = "vnet-test-cu-dev-kmi-0"

    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    sku                = "Basic"
    copy_paste_enabled = false # Explicitly disable
  }

  assert {
    condition     = output.copy_paste_enabled == false
    error_message = "Copy/paste must be disabled when explicitly set to false"
  }
}
