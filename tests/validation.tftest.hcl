# =============================================================================
# Input Validation Tests
# =============================================================================
#
# These tests validate that input variables are properly constrained and
# that invalid inputs trigger appropriate validation errors.
#

# Configure Azure provider for tests
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Test: Invalid SKU value
run "test_invalid_sku" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "dev"
    location    = "centralus"
    repository  = "test-repo"
    workload    = "test"

    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    sku = "InvalidSKU"
  }

  expect_failures = [
    var.sku,
  ]
}

# Test: Scale units below minimum (2)
run "test_scale_units_below_minimum" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "dev"
    location    = "centralus"
    repository  = "test-repo"
    workload    = "test"

    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    sku         = "Standard"
    scale_units = 1
  }

  expect_failures = [
    var.scale_units,
  ]
}

# Test: Scale units above maximum (50)
run "test_scale_units_above_maximum" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "dev"
    location    = "centralus"
    repository  = "test-repo"
    workload    = "test"

    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    sku         = "Standard"
    scale_units = 51
  }

  expect_failures = [
    var.scale_units,
  ]
}

# Test: Invalid subnet prefix (too small - /27)
run "test_invalid_subnet_prefix_too_small" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "dev"
    location    = "centralus"
    repository  = "test-repo"
    workload    = "test"

    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/27" # Too small, minimum is /26
    create_public_ip      = true
  }

  expect_failures = [
    var.subnet_address_prefix,
  ]
}

# Test: Invalid subnet prefix format
run "test_invalid_subnet_prefix_format" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "dev"
    location    = "centralus"
    repository  = "test-repo"
    workload    = "test"

    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "not-a-cidr"
    create_public_ip      = true
  }

  expect_failures = [
    var.subnet_address_prefix,
  ]
}

# Test: Missing existing_public_ip_name when create_public_ip is false
run "test_missing_existing_public_ip_name" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "dev"
    location    = "centralus"
    repository  = "test-repo"
    workload    = "test"

    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = false
    # Missing: existing_public_ip_name
  }

  expect_failures = [
    var.existing_public_ip_name,
  ]
}

# Test: Invalid environment value
run "test_invalid_environment" {
  command = plan

  variables {
    contact               = "test@example.com"
    environment           = "invalid"
    location              = "centralus"
    repository            = "test-repo"
    workload              = "test"
    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true
  }

  expect_failures = [
    var.environment,
  ]
}

# Test: Invalid location value
run "test_invalid_location" {
  command = plan

  variables {
    contact               = "test@example.com"
    environment           = "dev"
    location              = "invalid-region"
    repository            = "test-repo"
    workload              = "test"
    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true
  }

  expect_failures = [
    var.location,
  ]
}

# Test: Invalid contact format
run "test_invalid_contact_format" {
  command = plan

  variables {
    contact               = "not-an-email"
    environment           = "dev"
    location              = "centralus"
    repository            = "test-repo"
    workload              = "test"
    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true
  }

  expect_failures = [
    var.contact,
  ]
}

# Test: Empty resource_group_name
run "test_empty_resource_group_name" {
  command = plan

  variables {
    contact               = "test@example.com"
    environment           = "dev"
    location              = "centralus"
    repository            = "test-repo"
    workload              = "test"
    resource_group_name   = ""
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true
  }

  expect_failures = [
    var.resource_group_name,
  ]
}

# Test: Empty virtual_network_name
run "test_empty_virtual_network_name" {
  command = plan

  variables {
    contact               = "test@example.com"
    environment           = "dev"
    location              = "centralus"
    repository            = "test-repo"
    workload              = "test"
    resource_group_name   = "rg-test"
    virtual_network_name  = ""
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true
  }

  expect_failures = [
    var.virtual_network_name,
  ]
}

# Test: Empty workload
run "test_empty_workload" {
  command = plan

  variables {
    contact               = "test@example.com"
    environment           = "dev"
    location              = "centralus"
    repository            = "test-repo"
    workload              = ""
    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true
  }

  expect_failures = [
    var.workload,
  ]
}

# Test: Workload too long
run "test_workload_too_long" {
  command = plan

  variables {
    contact               = "test@example.com"
    environment           = "dev"
    location              = "centralus"
    repository            = "test-repo"
    workload              = "this-workload-name-is-way-too-long-for-validation"
    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true
  }

  expect_failures = [
    var.workload,
  ]
}

# Test: Missing log_analytics_workspace_id when diagnostics enabled
run "test_missing_log_analytics_workspace_id" {
  command = plan

  variables {
    contact               = "test@example.com"
    environment           = "dev"
    location              = "centralus"
    repository            = "test-repo"
    workload              = "test"
    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    enable_diagnostics = true
    # Missing: log_analytics_workspace_id
  }

  expect_failures = [
    var.log_analytics_workspace_id,
  ]
}

# Test: Invalid log_analytics_destination_type
run "test_invalid_log_analytics_destination_type" {
  command = plan

  variables {
    contact               = "test@example.com"
    environment           = "dev"
    location              = "centralus"
    repository            = "test-repo"
    workload              = "test"
    resource_group_name   = "rg-test"
    virtual_network_name  = "vnet-test"
    create_subnet         = true
    subnet_address_prefix = "10.0.255.0/26"
    create_public_ip      = true

    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/test/workspaces/test"
    log_analytics_destination_type = "Invalid"
  }

  expect_failures = [
    var.log_analytics_destination_type,
  ]
}
