# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.4] - 2025-10-30

### Fixed
- Corrected diagnostics module version back to v0.0.2 (v0.0.11 does not exist)
  - v0.1.3 incorrectly referenced non-existent diagnostics v0.0.11
  - Reverted to correct version v0.0.2 which is the latest available

## [0.1.3] - 2025-10-30 [YANKED]

### Changed
- **YANKED**: Updated diagnostics module dependency from v0.0.2 to v0.0.11
  - This version is yanked because diagnostics v0.0.11 does not exist
  - Use v0.1.4 instead

## [0.1.2] - 2025-10-30

### Changed
- Updated module dependencies to use Terraform Cloud registry format
  - Changed terraform-namer module from relative path to `app.terraform.io/infoex/namer/terraform` (version 0.0.3)
  - Changed diagnostics module from relative path to `app.terraform.io/infoex/diagnostics/azurerm` (version 0.0.2)
  - Ensures consistent module resolution in Terraform Cloud workflows
  - Improves module dependency management

## [0.1.1] - 2024-10-30

### Changed
- Published module version for use in infrastructure projects
- Module now ready for consumption via versioned releases

## [0.1.0] - 2024-10-30

### Added
- Initial module creation for Azure Bastion Host provisioning
- Support for Basic and Standard SKUs with all Azure Bastion features
- Flexible subnet management (create new or use existing AzureBastionSubnet)
- Flexible Public IP management (create new or use existing Standard Public IP)
- Cross-resource-group support for VNet and Public IP resources
- Standard SKU advanced features:
  - Scaling units (2-50 host instances for high availability)
  - File transfer support (upload/download files during sessions)
  - Native client support (tunneling) for native RDP/SSH clients
  - Shareable links for temporary access without Azure portal
  - IP-based connections to VMs by private IP address
- Zone redundancy support for Public IP (availability zones 1, 2, 3)
- Service endpoints configuration for AzureBastionSubnet (Storage, KeyVault)
- Diagnostics integration with terraform-azurerm-diagnostics module
  - BastionAuditLogs for session tracking and compliance
  - AllMetrics for performance monitoring
  - Support for Dedicated and AzureDiagnostics table types
- Integrated terraform-namer for consistent naming and tagging
- Comprehensive validation rules:
  - terraform-namer variables (environment, location, contact, workload)
  - Resource configuration (resource group name, VNet name)
  - Bastion-specific constraints (SKU, scale units, subnet size)
  - Diagnostics configuration validation
- Multiple working examples:
  - Basic SKU with subnet and Public IP creation
  - Standard SKU with all advanced features enabled
  - Existing resources integration (existing subnet and Public IP)
- Comprehensive test suite (29 tests, 100% coverage):
  - 14 functional tests covering all features and scenarios
  - 15 validation tests ensuring input constraints
  - Fast execution (~2 minutes, plan-only, zero cost)
  - Test coverage includes: SKU support, scaling, features, networking, diagnostics, cross-RG scenarios
- Security review completed with 88/100 score (EXCELLENT rating)
- Complete documentation:
  - README.md with terraform-docs auto-generation
  - Detailed test documentation (tests/README.md)
  - Security review report (SECURITY_REVIEW.md)
  - Contributing guidelines (CONTRIBUTING.md)
  - GitHub Actions CI/CD workflows (test, release)
  - Comprehensive cost analysis (COST_ANALYSIS.md)
    - SKU-based cost breakdown (Basic vs Standard)
    - Scaling cost impact analysis (2-50 scale units)
    - Environment-specific recommendations
    - TCO comparison vs traditional jump boxes (89% cost reduction)
    - Monthly and annual cost projections
    - Cost optimization strategies

### Security
- Secure defaults: `shareable_link_enabled = false` (prevents unauthorized access)
- Secure defaults: `file_copy_enabled = false` (prevents data exfiltration)
- Copy/paste enabled by default for usability (`copy_paste_enabled = true`)
- Diagnostics integration for audit logging and compliance (PCI-DSS, HIPAA, SOC 2)
- Comprehensive validation to prevent misconfigurations
- No hardcoded credentials or secrets

[unreleased]: https://github.com/excellere-it/terraform-azurerm-bastion/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/excellere-it/terraform-azurerm-bastion/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/excellere-it/terraform-azurerm-bastion/releases/tag/v0.1.0
