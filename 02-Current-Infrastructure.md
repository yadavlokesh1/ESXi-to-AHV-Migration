# Current Infrastructure - VMware ESXi Environment

## Overview

This document details the existing VMware vSphere infrastructure that serves as the source environment for migration to Nutanix AHV.

## VMware Environment Architecture

### Environment Summary

| Component | Count |
|-----------|-------|
| ESXi Hosts | 4 |
| Virtual Machines | 120 |
| Datastores | 8 |
| VLANs | 6 |
| Storage Capacity | 50 TB Usable |
| vCenter Servers | 1 |

### ESXi Host Configuration

| Host | Model | CPU | RAM | Storage Role |
|------|-------|-----|-----|--------------|
| ESXi-Host-01 | Dell R740 | 2x Intel Xeon Gold 6248R (48 cores) | 384 GB | Compute + Storage |
| ESXi-Host-02 | Dell R740 | 2x Intel Xeon Gold 6248R (48 cores) | 384 GB | Compute + Storage |
| ESXi-Host-03 | Dell R740 | 2x Intel Xeon Gold 6248R (48 cores) | 384 GB | Compute + Storage |
| ESXi-Host-04 | Dell R740 | 2x Intel Xeon Gold 6248R (48 cores) | 384 GB | Compute + Storage |

**Total Cluster Resources:**
- vCPU: 192 cores
- Memory: 1.5 TB
- ESXi Version: 7.0 Update 3 (Build 20328353)

### vCenter Server Configuration

| Component | Details |
|-----------|---------|
| Version | vCenter Server 7.0 Update 3 |
| Deployment | Windows-based installation |
| Management Network | 192.168.10.0/24 |
| Host Count | 4 ESXi hosts |
| Clusters | 1 production cluster |
| DRS | Enabled (Fully Automated) |
| HA | Enabled (Host failures: 1, VM restart priority: Medium) |

### Storage Infrastructure

**SAN Configuration:**

| Component | Specification |
|-----------|--------------|
| Storage Array | Dell EMC Unity 380F |
| Protocol | iSCSI |
| Total Capacity | 80 TB raw, 50 TB usable (RAID 6) |
| Network | Dedicated 10GbE storage network |
| Datastores | 8 VMFS datastores |
| Average Utilization | 65% (32.5 TB used) |

**Datastore Layout:**

| Datastore | Size | Usage | VM Count | Purpose |
|-----------|------|-------|----------|---------|
| Production_DS01 | 8 TB | 5.2 TB | 25 | Production VMs |
| Production_DS02 | 8 TB | 6.1 TB | 30 | Production VMs |
| Production_DS03 | 6 TB | 3.8 TB | 18 | Database servers |
| FileServer_DS01 | 10 TB | 8.2 TB | 8 | File server VMs |
| App_DS01 | 6 TB | 4.1 TB | 20 | Application servers |
| Dev_DS01 | 4 TB | 2.1 TB | 12 | Development VMs |
| Test_DS01 | 4 TB | 1.8 TB | 5 | Test environments |
| Backup_DS01 | 4 TB | 1.2 TB | 2 | Backup appliances |

### Network Configuration

**Physical Network:**

| Network Type | VLAN ID | Subnet | Gateway | Purpose |
|--------------|---------|--------|---------|---------|
| Management | VLAN 10 | 192.168.10.0/24 | .1 | ESXi management, vCenter |
| Production | VLAN 20 | 10.10.20.0/24 | .1 | Production VM network |
| DMZ | VLAN 30 | 10.10.30.0/24 | .1 | Public-facing services |
| Storage | VLAN 40 | 192.168.40.0/24 | .1 | iSCSI traffic |
| Backup | VLAN 50 | 192.168.50.0/24 | .1 | Backup network |
| Development | VLAN 60 | 10.10.60.0/24 | .1 | Dev/test VMs |

**vSwitch Configuration:**

- **vSwitch0:** Management network (VLAN 10)
- **vSwitch1:** Production + DMZ (VLANs 20, 30)
- **vSwitch2:** Storage network (VLAN 40) - dedicated 10GbE NICs
- **vSwitch3:** Backup + Development (VLANs 50, 60)

## Virtual Machine Inventory

## Assessment Findings

The current VMware environment is healthy and adequately sized for existing workloads. However, increasing licensing costs, aging infrastructure components, and growing storage demands create a strong business case for migration to Nutanix AHV.

Key findings include:

- Cluster resource utilization remains below 70%
- Storage consumption currently at 65%
- VMware renewal costs increased significantly
- Multiple workloads running on aging operating systems
- Existing backup platform supports migration requirements

### Total VM Count: 120

**By Operating System:**

| OS | Count | Notes |
|----|-------|-------|
| Windows Server 2019 | 45 | Domain controllers, file servers, app servers |
| Windows Server 2016 | 28 | Legacy applications, SQL servers |
| Windows Server 2012 R2 | 12 | Older apps pending upgrade |
| Red Hat Enterprise Linux 8 | 18 | Web servers, containerized apps |
| Ubuntu 20.04 LTS | 10 | Development, testing |
| CentOS 7 | 7 | Monitoring, logging systems |

**By Resource Allocation:**

| vCPU Range | VM Count | RAM Range | VM Count |
|------------|----------|-----------|----------|
| 2 vCPU | 35 | 4 GB | 28 |
| 4 vCPU | 48 | 8 GB | 42 |
| 8 vCPU | 25 | 16 GB | 30 |
| 16 vCPU | 12 | 32 GB | 15 |
| | | 64 GB | 5 |

**Critical Workloads (Top Priority for Migration):**

| VM Name | vCPU | RAM | Storage | Role | Downtime Tolerance |
|---------|------|-----|---------|------|-------------------|
| DC01 | 4 | 8 GB | 120 GB | Domain Controller | <15 min |
| DC02 | 4 | 8 GB | 120 GB | Domain Controller | <15 min |
| SQL-PROD-01 | 16 | 64 GB | 1.2 TB | SQL Server Production | <30 min |
| SQL-PROD-02 | 16 | 64 GB | 1.2 TB | SQL Server (AlwaysOn) | <30 min |
| FileServer-01 | 8 | 32 GB | 4 TB | Main file server | <1 hour |
| Exchange-01 | 8 | 32 GB | 800 GB | Email server | <1 hour |
| WebApp-LB | 4 | 16 GB | 200 GB | Load balancer | <30 min |

## Backup and Recovery

**Backup Solution:**

| Component | Details |
|-----------|---------|
| Software | Veeam Backup & Replication 12 |
| Repository | Dell EMC Data Domain DD3300 |
| Backup Window | Daily, 11 PM - 5 AM |
| Retention | 14 days incremental, monthly full for 12 months |
| Recovery Point Objective (RPO) | 24 hours |
| Recovery Time Objective (RTO) | 4 hours for critical VMs |

**Backup Status:**
- All 120 VMs backed up successfully
- Average backup size: 18 TB
- Backup success rate: 99.2% (last 30 days)
- Last full backup: Verified within 7 days of migration start

## Performance Baselines

**Cluster-Level Metrics (30-day average):**

| Metric | Average | Peak | Notes |
|--------|---------|------|-------|
| CPU Utilization | 42% | 68% | Peak during business hours |
| Memory Utilization | 58% | 72% | Consistent usage |
| Storage Latency | 8 ms | 15 ms | Acceptable for workload mix |
| Network Throughput | 2.4 Gbps | 6.8 Gbps | Backup window peaks |

**VM-Level Performance (Critical Workloads):**

| VM | CPU % | Memory % | Disk IOPS | Notes |
|----|-------|----------|-----------|-------|
| SQL-PROD-01 | 35% | 82% | 1,200 | High disk activity |
| SQL-PROD-02 | 28% | 78% | 980 | Secondary replica |
| FileServer-01 | 18% | 65% | 450 | Read-heavy workload |
| Exchange-01 | 22% | 68% | 320 | Email I/O |

## Licensing Information

## Capacity Analysis

Based on current utilization metrics:

- CPU headroom available: approximately 58%
- Memory headroom available: approximately 42%
- Storage headroom available: approximately 35%

Current workload consumption indicates sufficient capacity for migration into a 4-node Nutanix cluster while maintaining operational reserves.

**VMware Licensing Costs (Annual):**

| Product | License Type | Cost |
|---------|-------------|------|
| vSphere Enterprise Plus | Per-CPU (8 sockets) | $42,000 |
| vCenter Server Standard | Per-instance | $6,000 |
| vSAN (if used) | N/A | N/A |
| vRealize Suite | Not deployed | $0 |
| NSX (if used) | N/A | N/A |
| Support & Subscription | 20% of license cost | $9,600 |
| **Total Annual Cost** | | **$57,600** |

**Post-Broadcom Renewal Quote:** $78,000+ (35% increase)

## Known Issues and Limitations

### Current Pain Points

1. **Licensing Costs**
   - 35% increase in renewal costs
   - Forced bundling of unused products
   - Per-core pricing increasing with hardware refresh

2. **Management Complexity**
   - Separate tools for compute, storage, backup
   - Multiple vendor support contracts
   - Complex upgrade cycles

3. **Storage Limitations**
   - SAN reaching capacity (65% utilized)
   - Performance bottlenecks during backup windows
   - Expensive capacity expansion

4. **Operational Overhead**
   - Manual VM provisioning (15-30 minutes)
   - Patching requires multiple tools
   - Limited automation capabilities

### Technical Debt

- 12 VMs running Windows Server 2012 R2 (approaching EOL)
- ESXi hosts aging (5 years old)
- SAN nearing end-of-support
- Lack of disaster recovery automation

## Dependencies for Migration

## Migration Readiness Assessment

| Area | Status |
|--------|--------|
| VM Inventory | Complete |
| Backup Validation | Complete |
| Network Assessment | Complete |
| Capacity Assessment | Complete |
| Application Review | Complete |
| Migration Tool Selection | Complete |
| Stakeholder Approval | Pending |

**Prerequisites:**

1. **Nutanix Cluster Operational**
   - 4-node cluster deployed and configured
   - Prism Central installed
   - Network VLANs configured

2. **Network Readiness**
   - VLANs created on Nutanix
   - IP address planning complete
   - DNS records prepared

3. **Application Owner Coordination**
   - Migration schedules confirmed
   - Testing resources allocated
   - Downtime windows approved

4. **Backup Verification**
   - All VMs backed up within 24 hours
   - Test restores validated
   - Backup retention extended during migration

---

*Document Version: 1.1*  
*Last Updated: May 2026*  
*Author: Lokesh Yadav*
