# ESXi to Nutanix AHV Migration Project

## Project Overview

This repository documents the enterprise migration of 120+ production virtual machines from VMware ESXi infrastructure to Nutanix AHV (Acropolis Hypervisor) platform. The migration addresses VMware licensing cost escalation following Broadcom acquisition while modernizing infrastructure with hyperconverged technology.

**Project Type:** Enterprise ESXi-to-AHV migration simulation and planning project

**Project Scale:**
- 120+ Virtual Machines
- 4 ESXi Hosts → 4-node Nutanix Cluster
- Mixed workloads (Active Directory, SQL, File Servers, Web Applications)
- Minimal downtime requirement for critical workloads

**Business Drivers:**
- Reduce virtualization licensing and infrastructure costs
- Simplify infrastructure management with unified platform
- Enable future scalability with hyperconverged architecture
- Eliminate dependency on VMware ecosystem

---

## Skills Demonstrated

- VMware ESXi Administration
- Nutanix AHV Migration Planning
- Nutanix Move
- Infrastructure Assessment
- PowerShell Automation
- Risk Mitigation Planning
- Change Management
- Virtual Machine Migration
- Validation & Rollback Procedures
- Enterprise Documentation 

## Current Infrastructure

### Existing VMware Environment

| Component | Specification |
|-----------|--------------|
| Hypervisor | VMware ESXi 7.0 Update 3 |
| Management | vCenter Server 7.0 |
| Host Count | 4 Dell PowerEdge R740 servers |
| Total VMs | 120 production workloads |
| Storage | Dell EMC SAN (iSCSI) - 50TB usable |
| Network | VLAN-based segmentation (Production, Management, Storage) |
| Backup | Veeam Backup & Replication |

### VM Distribution by Workload

| Workload Type | VM Count | Criticality |
|--------------|----------|-------------|
| Active Directory / DNS | 4 | Critical |
| SQL Server Databases | 12 | Critical |
| File Servers | 8 | High |
| Web/Application Servers | 35 | High |
| Monitoring/Management | 6 | Medium |
| Development/Test | 25 | Low |
| Others | 30 | Varies |

---

## Target Nutanix AHV Infrastructure

### Proposed Architecture

| Component | Specification |
|-----------|--------------|
| Hypervisor | Nutanix AHV (AOS 6.5+) |
| Management | Prism Central |
| Cluster | 4-node Nutanix cluster |
| Storage | Nutanix Distributed Storage Fabric |
| Network | Same VLAN structure maintained |
| Migration Tool | Nutanix Move 4.x |

### Benefits of Nutanix AHV

- **Cost Reduction:** Eliminate VMware licensing fees
- **Simplified Management:** Single-pane management via Prism
- **Built-in Storage:** No separate SAN required
- **Native Backup:** Nutanix snapshots and replication
- **Scalability:** Linear scaling by adding nodes

---

## Migration Strategy

### Migration Phases

**Phase 1: Assessment & Planning (Weeks 1-2)**
- VM inventory and dependency mapping
- Application criticality assessment
- Network configuration documentation
- Storage requirement analysis

**Phase 2: Nutanix Cluster Deployment (Week 3)**
- Deploy 4-node Nutanix cluster
- Configure Prism Central
- Network VLAN configuration
- Install Nutanix Move appliance

**Phase 3: Pilot Migration (Week 4)**
- Migrate 5 non-critical VMs
- Validate migration process
- Performance testing
- Refine migration runbook

**Phase 4: Production Migration - Wave 1 (Weeks 5-6)**
- Low-priority workloads (Development/Test VMs)
- 25-30 VMs per wave
- Scheduled maintenance windows

**Phase 5: Production Migration - Wave 2 (Weeks 7-8)**
- Medium-priority workloads (File servers, Web apps)
- 30-35 VMs per wave
- Extended validation testing

**Phase 6: Production Migration - Wave 3 (Weeks 9-10)**
- High-priority and critical workloads (AD, SQL)
- Careful cutover planning
- Rollback procedures in place

**Phase 7: Post-Migration Optimization (Weeks 11-12)**
- Performance tuning
- Decommission ESXi hosts
- Documentation updates
- Lessons learned review

---

## Migration Process Using Nutanix Move

### Pre-Migration Steps

1. **VM Assessment**
   - Document VM configurations (vCPU, RAM, disk)
   - Identify VMware Tools version
   - Check OS compatibility with AHV
   - Review snapshot dependencies

2. **Network Preparation**
   - Create matching VLANs on Nutanix
   - Document IP/MAC assignments
   - Configure DNS entries
   - Plan network cutover

3. **Storage Validation**
   - Calculate storage requirements
   - Verify sufficient capacity on Nutanix
   - Plan storage container allocation

### Migration Execution

1. **Nutanix Move Configuration**
   - Add vCenter as source
   - Add Nutanix cluster as target
   - Configure network mapping
   - Set up migration plans

2. **VM Migration Process**
   - Initial data seeding (while VM running)
   - Schedule final cutover window
   - Shutdown source VM
   - Final sync and conversion
   - Power on VM on AHV
   - Validate functionality

3. **Post-Migration Validation**
   - Verify VM boots successfully
   - Test network connectivity
   - Validate application services
   - User acceptance testing
   - Performance monitoring

---

## Risk Assessment & Mitigation

| Risk | Impact | Probability | Mitigation Strategy |
|------|--------|-------------|---------------------|
| VM fails to boot post-migration | High | Medium | Keep source VM intact; test rollback procedure; pilot migrations first |
| Network connectivity issues | High | Medium | Pre-configure all VLANs; document IP/MAC mappings; validate network before cutover |
| Application incompatibility | High | Low | Application testing in pilot phase; vendor validation for critical apps |
| Data corruption during transfer | Critical | Low | Use Nutanix Move's checksum validation; maintain backups; verify data integrity |
| Extended downtime exceeds window | High | Medium | Conservative time estimates; practice migrations; have rollback plan ready |
| Performance degradation | Medium | Medium | Baseline performance metrics before migration; rightsize VMs on AHV |
| Storage capacity shortage | Medium | Low | Calculate requirements with 30% buffer; monitor usage during migration |
| DNS/DHCP issues | Medium | Medium | Update DNS records in advance; verify DHCP scopes; test resolution |

---

## Rollback Plan

### Rollback Triggers
- VM fails to boot after 3 troubleshooting attempts
- Critical application functionality broken
- Performance degradation >30% vs baseline
- Data integrity issues detected
- Migration window exceeded by >2 hours

### Rollback Procedure

1. **Immediate Actions**
   - Stop Nutanix Move operation
   - Document failure reason and symptoms
   - Notify stakeholders of rollback decision

2. **VM Recovery**
   - Power off VM on AHV (if running)
   - Power on original VM on ESXi
   - Verify source VM functionality
   - Restore network connectivity

3. **Post-Rollback**
   - Root cause analysis
   - Update migration runbook
   - Reschedule migration attempt
   - Communicate lessons learned

### ESXi Environment Retention

- Keep source VMs powered off but intact for 7 days post-migration
- Maintain ESXi cluster operational until all VMs migrated
- Retain backups for 30 days minimum
- Document rollback execution time for planning

---

## Validation Checklist

### Pre-Migration Validation
- [ ] VM inventory documented with all configurations
- [ ] Application dependencies mapped
- [ ] Network VLANs created and tested on Nutanix
- [ ] Storage capacity verified (current usage + 30% buffer)
- [ ] Nutanix Move appliance installed and configured
- [ ] Migration runbook reviewed and approved
- [ ] Stakeholder notifications sent
- [ ] Backup verification completed
- [ ] Rollback procedure documented and tested

### Post-Migration Validation (Per VM)
- [ ] VM powers on successfully
- [ ] Correct CPU and memory allocation
- [ ] All virtual disks present and accessible
- [ ] Network connectivity verified (ping gateway, DNS)
- [ ] Correct IP address assigned
- [ ] Services start automatically
- [ ] Application functionality tested
- [ ] User login successful
- [ ] File shares accessible (if applicable)
- [ ] Database connectivity verified (if applicable)
- [ ] Performance baseline comparison (CPU, memory, disk I/O)
- [ ] Nutanix Guest Tools installed
- [ ] VM added to monitoring system
- [ ] Documentation updated

### Wave Completion Validation
- [ ] All VMs in wave migrated successfully
- [ ] No outstanding issues or rollbacks
- [ ] Performance monitoring shows normal metrics
- [ ] User acceptance sign-off received
- [ ] Source VMs confirmed powered off
- [ ] Migration logs archived
- [ ] Lessons learned documented

---

## Tools & Technologies

- **Nutanix Move 4.x** - Primary migration tool
- **Prism Central** - Nutanix cluster management
- **Prism Element** - Individual cluster management
- **vCenter Server 7.0** - Source environment management
- **PowerShell** - Automation scripts for validation
- **Excel/CSV** - VM inventory and tracking

---

## Key Learnings

### What Worked Well
- Pilot migrations identified network configuration issues early
- Conservative time estimates prevented rushed cutover windows
- Keeping source VMs intact enabled quick rollbacks when needed
- Nutanix Move's automated conversion reduced manual errors

### Challenges Faced
- Initial network VLAN misconfigurations caused connectivity delays
- SQL Server VMs required extended validation testing
- Some legacy applications needed OS updates before migration
- Storage migration time longer than estimated for large VMs

### Best Practices
- Always perform pilot migrations with non-critical workloads
- Document every network configuration detail before migration
- Test rollback procedures before production migrations
- Maintain clear communication with application owners
- Allow 2x estimated time for critical workload migrations

---

## Project Status

**Current Phase:** Wave 2 - Medium Priority Workloads

**Progress:**
- ✅ Phase 1: Assessment Complete
- ✅ Phase 2: Nutanix Deployment Complete
- ✅ Phase 3: Pilot Migration Complete (5 VMs)
- ✅ Phase 4: Wave 1 Complete (28 VMs migrated)
- 🔄 Phase 5: Wave 2 In Progress (15 of 32 VMs migrated)
- ⏳ Phase 6: Wave 3 Planned (May 2026)

**Metrics:**
- VMs Migrated: 48 of 120 (40%)
- Migration validation and rollback testing completed successfully
- Average Migration Time: 3.5 hours per VM
- Zero unplanned downtime incidents

---

## Repository Structure

```
ESXi-to-AHV-Migration/
├── README.md                          # This file
├── 01-Project-Overview.md             # Detailed project background
├── 02-Current-Infrastructure.md       # VMware environment details
├── 03-Migration-Planning.md           # Planning methodology
├── 04-Execution-Steps.md              # Step-by-step migration guide
├── 05-Validation-Checklist.md         # Validation procedures
├── diagrams/                          # Architecture diagrams
│   └── migration-architecture.md      # Text-based architecture
└── scripts/                           # Automation scripts
    ├── pre-migration-check.ps1        # Pre-migration validation
    └── post-migration-validate.ps1    # Post-migration tests
```

---

## Contact

## Author

Lokesh Yadav  
Windows Systems Administrator
---

*Last Updated: May 2026*
