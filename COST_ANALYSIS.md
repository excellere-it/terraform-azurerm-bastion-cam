# Azure Bastion - Cost Analysis

## Executive Summary

Azure Bastion provides secure RDP/SSH connectivity without exposing VMs to the internet. This document analyzes the costs associated with deploying Azure Bastion using this Terraform module.

**Key Findings:**
- **Basic SKU**: ~$144/month (fixed cost) - suitable for dev/test environments
- **Standard SKU**: ~$144-$3,644/month (scales 2-50 units) - suitable for production
- **Cost vs Value**: Replaces jump boxes with public IPs, reducing attack surface
- **Break-even**: More cost-effective than 2+ dedicated jump box VMs

---

## Cost Components

### 1. Azure Bastion Host

The primary cost driver. Pricing is fixed per hour based on SKU and scale units.

#### Basic SKU
- **Cost**: ~$140.16/month (730 hours × $0.19/hour)
- **Includes**:
  - Unlimited outbound data transfer to target VMs
  - Copy/paste functionality
  - Session support for up to 25 concurrent connections
- **Limitations**:
  - No file transfer
  - No native client support
  - No scaling
  - No IP-based connections

#### Standard SKU
- **Base Cost**: ~$140.16/month (2 scale units)
- **Additional Scale Units**: ~$70.08/month per unit
- **Scale Range**: 2-50 units
- **Cost Range**: $140-$3,644/month

**Scale Unit Pricing Table:**

| Scale Units | Concurrent Sessions | Monthly Cost | Use Case |
|-------------|---------------------|--------------|----------|
| 2 (minimum) | 50 sessions | $140 | Small production (< 50 users) |
| 4 | 100 sessions | $280 | Medium production (50-100 users) |
| 10 | 250 sessions | $701 | Large production (100-250 users) |
| 20 | 500 sessions | $1,402 | Enterprise (250-500 users) |
| 50 (maximum) | 1,250 sessions | $3,504 | Large enterprise (500+ users) |

**Formula**: `Monthly Cost = $140.16 + ((scale_units - 2) × $70.08)`

### 2. Public IP Address

Azure Bastion requires a Standard SKU Static Public IP.

- **Cost**: ~$3.65/month (730 hours × $0.005/hour)
- **Note**: Single IP shared by all Bastion connections
- **Zone Redundancy**: No additional cost for zones (availability feature)

### 3. AzureBastionSubnet

The dedicated subnet has minimal direct costs.

- **Subnet Cost**: $0 (no charge for subnets themselves)
- **Minimum Size**: /26 (64 IP addresses)
- **Recommended Size**: /26 for most deployments
- **IP Address Cost**: $0 (private IPs are free)

### 4. Diagnostics and Monitoring

Optional but recommended for compliance and troubleshooting.

#### Log Analytics Workspace
- **Ingestion Cost**: ~$2.76/GB for first 5 GB, then $2.30/GB
- **Retention**: First 31 days free, then $0.12/GB/month
- **Estimated Volume**:
  - Low usage (< 50 sessions/day): ~1-2 GB/month = ~$3-6/month
  - Medium usage (50-200 sessions/day): ~3-8 GB/month = ~$7-18/month
  - High usage (200+ sessions/day): ~10-20 GB/month = ~$23-46/month

#### Diagnostic Logs Captured
- **BastionAuditLogs**: Session tracking, authentication events
- **AllMetrics**: Performance metrics (CPU, memory, session count)

### 5. Data Transfer

**Outbound Data Transfer (Egress):**

| Destination | Monthly Data | Cost/GB | Monthly Cost |
|-------------|--------------|---------|--------------|
| To Azure VMs (same region) | Unlimited | $0 | $0 |
| To Azure VMs (cross-region) | Varies | $0.02 | Variable |
| Internet egress | N/A | N/A | N/A* |

*Note: Azure Bastion connections are to internal VMs only, so internet egress doesn't apply to Bastion traffic

---

## Cost Scenarios

### Scenario 1: Development Environment (Basic SKU)

**Configuration:**
- SKU: Basic
- Public IP: Standard Static
- Diagnostics: Enabled (low usage)

**Monthly Cost Breakdown:**
```
Azure Bastion (Basic)         $140.16
Public IP (Standard)            $3.65
Log Analytics (~2 GB)           $5.00
───────────────────────────────────
Total Monthly Cost:           $148.81
```

**Annual Cost**: ~$1,786

**Use Case**:
- Dev/test environments
- Small teams (< 25 concurrent users)
- Non-production workloads
- Cost-sensitive deployments

### Scenario 2: Small Production (Standard SKU, 2 Scale Units)

**Configuration:**
- SKU: Standard
- Scale Units: 2 (50 concurrent sessions)
- Public IP: Standard Static
- Diagnostics: Enabled (medium usage)
- Features: File transfer, tunneling, IP connect

**Monthly Cost Breakdown:**
```
Azure Bastion (Standard, 2 units)  $140.16
Public IP (Standard)                 $3.65
Log Analytics (~5 GB)               $12.00
───────────────────────────────────────
Total Monthly Cost:                $155.81
```

**Annual Cost**: ~$1,870

**Use Case**:
- Small production environments
- 25-50 concurrent users
- Advanced features required (file transfer, native client)
- Compliance requirements (audit logging)

### Scenario 3: Medium Production (Standard SKU, 4 Scale Units)

**Configuration:**
- SKU: Standard
- Scale Units: 4 (100 concurrent sessions)
- Public IP: Standard Static (zone-redundant)
- Diagnostics: Enabled (high usage)

**Monthly Cost Breakdown:**
```
Azure Bastion (Standard, 4 units)  $280.32
Public IP (Standard)                 $3.65
Log Analytics (~10 GB)              $25.00
───────────────────────────────────────
Total Monthly Cost:                $308.97
```

**Annual Cost**: ~$3,708

**Use Case**:
- Medium production environments
- 50-100 concurrent users
- High availability requirements
- Active development teams

### Scenario 4: Large Enterprise (Standard SKU, 10 Scale Units)

**Configuration:**
- SKU: Standard
- Scale Units: 10 (250 concurrent sessions)
- Public IP: Standard Static (zone-redundant)
- Diagnostics: Enabled (very high usage)

**Monthly Cost Breakdown:**
```
Azure Bastion (Standard, 10 units)  $701.44
Public IP (Standard)                  $3.65
Log Analytics (~20 GB)               $46.00
────────────────────────────────────────
Total Monthly Cost:                 $751.09
```

**Annual Cost**: ~$9,013

**Use Case**:
- Large production environments
- 100-250 concurrent users
- Multiple teams and applications
- Enterprise-scale operations

### Scenario 5: Maximum Scale (Standard SKU, 50 Scale Units)

**Configuration:**
- SKU: Standard
- Scale Units: 50 (1,250 concurrent sessions)
- Public IP: Standard Static (zone-redundant)
- Diagnostics: Enabled (enterprise usage)

**Monthly Cost Breakdown:**
```
Azure Bastion (Standard, 50 units)  $3,504.00
Public IP (Standard)                    $3.65
Log Analytics (~50 GB)                $115.00
──────────────────────────────────────────
Total Monthly Cost:                 $3,622.65
```

**Annual Cost**: ~$43,472

**Use Case**:
- Very large enterprise environments
- 500-1,250 concurrent users
- Global teams with 24/7 operations
- Mission-critical infrastructure

---

## Cost Comparison: Bastion vs Traditional Jump Box

### Traditional Jump Box Approach

**Resources Required:**
- Windows VM (jump box): Standard_D2s_v3
- Public IP: Standard Static
- Managed disk: 128 GB Premium SSD
- NSG rules management
- Patching and maintenance

**Monthly Cost:**
```
VM (Standard_D2s_v3)              $70.08
Public IP                           $3.65
OS Disk (128GB Premium)            $19.71
──────────────────────────────────────
Total per Jump Box:                $93.44
```

**For High Availability** (2 jump boxes):
```
2 × Jump Boxes                    $186.88
Load Balancer (Basic)              $18.25
──────────────────────────────────────
Total HA Setup:                   $205.13
```

### Azure Bastion Comparison

| Solution | Monthly Cost | Concurrent Users | Maintenance | Security |
|----------|-------------|------------------|-------------|----------|
| Single Jump Box | $93 | Limited by VM | High | Medium |
| HA Jump Boxes (2) | $205 | Limited | Very High | Medium |
| **Bastion Basic** | **$149** | **25** | **None** | **High** |
| **Bastion Standard (2 units)** | **$156** | **50** | **None** | **High** |
| **Bastion Standard (4 units)** | **$309** | **100** | **None** | **High** |

**Key Advantages of Azure Bastion:**
- ✅ **Zero Maintenance**: Fully managed PaaS (no patching, no OS updates)
- ✅ **Better Security**: No public IPs on VMs, integrated with Azure AD
- ✅ **Native HA**: Built-in high availability with Standard SKU
- ✅ **Compliance**: Built-in audit logging (PCI-DSS, HIPAA, SOC 2)
- ✅ **Scalability**: Scale from 2-50 units on-demand
- ✅ **No Additional Software**: Works through browser or native client

**Break-Even Analysis:**
- **1 Jump Box**: Bastion costs ~$56/month more BUT eliminates maintenance
- **2 Jump Boxes (HA)**: Bastion Standard (4 units) costs ~$104/month more but scales better
- **Hidden Costs**: Jump box maintenance time (~8 hours/month × $100/hour) = $800/month
- **True TCO**: Bastion is **significantly cheaper** when including operational overhead

---

## Cost Optimization Strategies

### 1. Choose Appropriate SKU by Environment

#### Development/Testing
```hcl
# Use Basic SKU for dev/test
module "bastion_dev" {
  source = "path/to/terraform-azurerm-bastion"

  sku = "Basic"  # $140/month

  contact     = "devops@company.com"
  environment = "dev"
  location    = "centralus"
  workload    = "bastion"

  # ... other config ...
}

# Monthly cost: ~$149
# Savings vs Standard: ~$7/month (5%)
```

#### Production
```hcl
# Use Standard SKU for production with right-sized scale units
module "bastion_prod" {
  source = "path/to/terraform-azurerm-bastion"

  sku         = "Standard"
  scale_units = 4  # Start small, scale up if needed

  contact     = "ops@company.com"
  environment = "prd"
  location    = "centralus"
  workload    = "bastion"

  # Enable diagnostics for compliance
  enable_diagnostics         = true
  log_analytics_workspace_id = var.law_id

  # ... other config ...
}

# Monthly cost: ~$309
# Supports 100 concurrent users
```

### 2. Right-Size Scale Units

**Monitoring Approach:**
```bash
# Check current session count
az monitor metrics list \
  --resource /subscriptions/.../bastionHosts/bas-name \
  --metric "Sessions" \
  --start-time 2024-10-01 \
  --end-time 2024-10-28 \
  --interval PT1H

# If max concurrent sessions < 40, reduce to 2 scale units
# If max concurrent sessions 40-90, use 4 scale units
# If max concurrent sessions 90-240, use 10 scale units
```

**Scaling Strategy:**
- **Start Conservative**: Begin with 2 scale units (50 sessions)
- **Monitor Utilization**: Track for 30 days
- **Scale Up If**:
  - Average utilization > 70% of capacity
  - Peak utilization reaches 90%+
  - User complaints about connectivity
- **Scale Down If**:
  - Average utilization < 40% of capacity for 30+ days
  - Peak never exceeds 50% of capacity

**Example Scaling Decision:**
```
Current: 4 scale units (100 sessions) = $280/month
Observed peak: 35 concurrent sessions (35% utilization)

Recommendation: Scale down to 2 units (50 sessions) = $140/month
Savings: $140/month = $1,680/year (50% reduction)
```

### 3. Optimize Log Analytics Retention

**Default Configuration** (recommended):
```hcl
enable_diagnostics         = true
log_analytics_workspace_id = var.law_id

# Log Analytics workspace retention (configured separately)
# First 31 days: Free
# Days 32-730: $0.12/GB/month
```

**Cost Optimization:**
```hcl
# For dev/test: Consider disabling diagnostics
enable_diagnostics = false  # Saves $5-25/month

# For production: Use appropriate retention
# - 90 days for normal operations (~$24/month)
# - 365 days for compliance (PCI-DSS) (~$120/month)
# - 730 days for strict compliance (HIPAA) (~$240/month)
```

**Retention Cost Example:**
```
Log volume: 10 GB/month
Retention: 90 days (3 months)

Storage cost:
- Month 1: 10 GB × $0 (first 31 days free) = $0
- Month 2: 10 GB × $0.12 × 2 = $2.40
- Month 3: 10 GB × $0.12 × 3 = $3.60
Average monthly cost: ~$2.00

Retention: 365 days (12 months)
Average monthly cost: ~$7.20

Savings potential: $5.20/month by optimizing retention
```

### 4. Consolidate Bastion Deployments

**Anti-Pattern** (expensive):
```
# DON'T: One Bastion per environment
Bastion Dev (Basic)       $149/month
Bastion Stg (Basic)       $149/month
Bastion Prd (Standard 2)  $156/month
────────────────────────────────
Total:                    $454/month
```

**Optimized Pattern** (cost-effective):
```
# DO: Single Bastion in hub VNet with peering
Bastion Hub (Standard 4)  $309/month
────────────────────────────────
Total:                    $309/month
Savings:                  $145/month (32%)
```

**Hub-and-Spoke Architecture:**
```
┌─────────────────────────────────────┐
│ Hub VNet (Shared Services)          │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ Azure Bastion (Standard, 4)    │ │ ─────── $309/month
│  │ • Serves all environments      │ │
│  │ • 100 concurrent sessions      │ │
│  └────────────────────────────────┘ │
│                                      │
└──────────┬───────────────────┬───────┘
           │ VNet Peering      │ VNet Peering
     ┌─────▼──────┐      ┌────▼──────┐
     │  Dev VNet  │      │ Prod VNet │
     │  • No      │      │ • No      │
     │    Bastion │      │   Bastion │
     └────────────┘      └───────────┘

Total cost: $309/month vs $454/month (3 separate Bastions)
Savings: $145/month = $1,740/year
```

### 5. Use Appropriate Region

Azure Bastion pricing is consistent across regions, but consider:

**Cost Factors:**
- **Bastion Cost**: Same in all regions
- **Data Transfer**: Cross-region charges apply
- **Log Analytics**: Regional pricing varies slightly

**Recommendation:**
- Deploy Bastion in same region as VMs (zero data transfer cost)
- For multi-region: One Bastion per region (avoid cross-region charges)

### 6. Implement Usage Policies

**Policy Recommendations:**
```markdown
# Bastion Usage Policy

## Access Management
- Use Azure RBAC for access control
- Grant minimum necessary permissions
- Audit access quarterly

## Session Management
- Maximum session duration: 8 hours (auto-disconnect)
- Close sessions when not in use
- Monitor for orphaned sessions

## Feature Usage
- File transfer: Only for approved data
- Native client: Only for power users
- Shareable links: Disabled by default (security)

## Cost Accountability
- Tag all resources with cost center
- Monthly cost review by team leads
- Chargeback to business units
```

---

## Cost Tracking and Monitoring

### 1. Cost Allocation Tags

**Implement in Terraform:**
```hcl
module "bastion" {
  source = "path/to/terraform-azurerm-bastion"

  # ... config ...

  # terraform-namer automatically adds:
  # - company
  # - contact
  # - environment
  # - location
  # - repository
  # - workload

  # These tags enable cost tracking by:
  # - Environment (dev/stg/prd)
  # - Business unit (workload)
  # - Owner (contact)
}
```

**Azure Cost Management Query:**
```bash
# Get Bastion costs by environment
az costmanagement query \
  --type Usage \
  --scope "/subscriptions/YOUR_SUBSCRIPTION_ID" \
  --timeframe MonthToDate \
  --dataset-filter "{\"and\":[{\"dimensions\":{\"name\":\"ResourceType\",\"operator\":\"In\",\"values\":[\"Microsoft.Network/bastionHosts\"]}},{\"tags\":{\"name\":\"environment\",\"operator\":\"In\",\"values\":[\"dev\",\"stg\",\"prd\"]}}]}"
```

### 2. Cost Alerts

**Set Up Budget Alerts:**
```bash
# Create monthly budget for Bastion resources
az consumption budget create \
  --budget-name "bastion-monthly-budget" \
  --amount 500 \
  --category Cost \
  --time-grain Monthly \
  --start-date 2024-01-01 \
  --end-date 2025-12-31 \
  --resource-group rg-network \
  --notifications \
    amount=400 \
    operator=GreaterThan \
    threshold=80 \
    contactEmails="team@company.com" \
  --notifications \
    amount=500 \
    operator=GreaterThanOrEqualTo \
    threshold=100 \
    contactEmails="manager@company.com"
```

### 3. Monthly Cost Review Checklist

```markdown
## Monthly Azure Bastion Cost Review

### Usage Analysis
- [ ] Review total monthly cost vs budget
- [ ] Check concurrent session metrics
- [ ] Analyze peak usage times
- [ ] Review scale unit utilization

### Optimization Opportunities
- [ ] Can we reduce scale units?
- [ ] Is Basic SKU sufficient for any environment?
- [ ] Can we consolidate multiple Bastions?
- [ ] Are diagnostics logs optimized?

### Cost Allocation
- [ ] Verify tags are applied correctly
- [ ] Update chargeback reports
- [ ] Communicate costs to business units

### Action Items
- [ ] Schedule scale unit adjustments
- [ ] Document cost optimization decisions
- [ ] Update forecast for next quarter
```

---

## TCO Analysis: 1-Year and 3-Year

### Development Environment (Basic SKU)

**1-Year TCO:**
```
Azure Bastion (Basic)           $1,682
Public IP                          $44
Log Analytics (~2 GB/mo)           $60
─────────────────────────────────────
Total 1-Year:                   $1,786

vs Traditional Jump Box:
Jump Box VM + IP + Disk           $1,121
Maintenance (8 hrs/mo × $100)     $9,600
Security incidents (1/year)       $5,000
─────────────────────────────────────
Total 1-Year:                   $15,721

Savings with Bastion: $13,935/year (89% reduction in TCO)
```

**3-Year TCO:**
```
Azure Bastion (Basic)           $5,046
Public IP                         $131
Log Analytics                     $180
─────────────────────────────────────
Total 3-Year:                   $5,357

vs Traditional Jump Box:
Jump Box VM + IP + Disk           $3,364
Reserved Instance discount        -$673
Maintenance (8 hrs/mo × $100)    $28,800
Security incidents (1/year × 3)  $15,000
VM replacements (2 rebuilds)      $2,000
─────────────────────────────────────
Total 3-Year:                   $48,491

Savings with Bastion: $43,134 over 3 years (89% reduction in TCO)
```

### Production Environment (Standard, 4 Scale Units)

**1-Year TCO:**
```
Azure Bastion (Standard, 4)     $3,364
Public IP                          $44
Log Analytics (~10 GB/mo)         $300
─────────────────────────────────────
Total 1-Year:                   $3,708

vs Traditional HA Jump Boxes (2):
2× Jump Box VMs + IPs + Disks     $2,462
Load Balancer                      $219
Maintenance (16 hrs/mo × $100)   $19,200
Security incidents (1/year)       $5,000
─────────────────────────────────────
Total 1-Year:                   $26,881

Savings with Bastion: $23,173/year (86% reduction in TCO)
```

**3-Year TCO:**
```
Azure Bastion (Standard, 4)    $10,091
Public IP                         $131
Log Analytics                     $900
─────────────────────────────────────
Total 3-Year:                  $11,122

vs Traditional HA Jump Boxes (2):
2× Jump Box VMs + IPs + Disks     $7,387
Reserved Instance discount       -$1,477
Load Balancer                      $657
Maintenance (16 hrs/mo × $100)   $57,600
Security incidents (1/year × 3)  $15,000
VM replacements (2 × 2 = 4)       $4,000
─────────────────────────────────────
Total 3-Year:                  $83,167

Savings with Bastion: $72,045 over 3 years (87% reduction in TCO)
```

---

## Cost Summary and Recommendations

### By Environment

| Environment | Recommended SKU | Scale Units | Monthly Cost | Annual Cost | Use Case |
|-------------|----------------|-------------|--------------|-------------|----------|
| **Dev** | Basic | N/A | $149 | $1,786 | < 25 concurrent users |
| **Test** | Basic | N/A | $149 | $1,786 | < 25 concurrent users |
| **Staging** | Standard | 2 | $156 | $1,870 | 25-50 users, production-like |
| **Production (Small)** | Standard | 2-4 | $156-$309 | $1,870-$3,708 | 25-100 users |
| **Production (Medium)** | Standard | 4-10 | $309-$751 | $3,708-$9,013 | 100-250 users |
| **Production (Large)** | Standard | 10-20 | $751-$1,472 | $9,013-$17,663 | 250-500 users |
| **Enterprise** | Standard | 20-50 | $1,472-$3,623 | $17,663-$43,472 | 500+ users |

### Key Recommendations

#### ✅ DO:
1. **Use Basic SKU for dev/test** - Saves ~5% vs Standard
2. **Right-size scale units** - Monitor and adjust based on actual usage
3. **Consolidate in hub VNet** - Saves 30-40% vs per-environment Bastions
4. **Enable diagnostics in production** - Essential for compliance (worth the $12-46/month)
5. **Start with 2 scale units** - Scale up based on metrics, not guesses
6. **Use zone-redundancy for production** - No additional cost, better availability

#### ❌ DON'T:
1. **Over-provision scale units** - Each unused unit costs $70/month
2. **Deploy multiple Bastions unnecessarily** - Use hub-and-spoke architecture
3. **Skip diagnostics in production** - Compliance violations cost more than $12/month
4. **Use Standard SKU in dev** - Basic is sufficient and saves $7/month
5. **Ignore utilization metrics** - Review monthly and right-size

### Cost-Benefit Analysis

**vs Traditional Jump Boxes:**
- ✅ **89% lower TCO** (including maintenance and security)
- ✅ **Zero maintenance overhead** (fully managed PaaS)
- ✅ **Better security posture** (no public IPs on VMs)
- ✅ **Built-in compliance** (audit logging, Azure AD integration)
- ✅ **Scalable on-demand** (2-50 scale units)

**Break-Even Point:**
- Azure Bastion pays for itself if you eliminate just **1 jump box** when factoring in maintenance time
- Typical ROI: **300-500%** in first year due to eliminated operational overhead

### Budget Planning

**Minimum Monthly Budget:**
- Dev/Test: $150-200/month (Basic SKU + diagnostics)
- Small Production: $200-350/month (Standard 2-4 units)
- Medium Production: $350-800/month (Standard 4-10 units)
- Large Enterprise: $800-4,000/month (Standard 10-50 units)

**Annual Budget:**
- Dev/Test: $1,800-2,400/year
- Small Production: $2,400-4,200/year
- Medium Production: $4,200-9,600/year
- Large Enterprise: $9,600-48,000/year

---

## Additional Resources

### Azure Bastion Pricing
- Official Pricing: https://azure.microsoft.com/en-us/pricing/details/azure-bastion/
- Pricing Calculator: https://azure.microsoft.com/en-us/pricing/calculator/

### Cost Management
- Azure Cost Management: https://azure.microsoft.com/en-us/products/cost-management/
- Azure Advisor: https://azure.microsoft.com/en-us/products/advisor/

### Documentation
- Azure Bastion Documentation: https://docs.microsoft.com/en-us/azure/bastion/
- Cost Optimization Best Practices: https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/cost-mgt-best-practices

---

## Cost Analysis Metadata

**Document Version**: 1.0
**Last Updated**: 2024-10-30
**Pricing Region**: US Central
**Currency**: USD
**Pricing Date**: October 2024

**Note**: Azure pricing may vary by region and is subject to change. Always verify current pricing using the Azure Pricing Calculator before making procurement decisions.

**Disclaimer**: This cost analysis is based on list pricing and typical usage patterns. Actual costs may vary based on specific usage, enterprise agreements, and promotional offers.
