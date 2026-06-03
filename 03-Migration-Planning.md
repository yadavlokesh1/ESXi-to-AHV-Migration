# Migration Planning - ESXi to Nutanix AHV

## Planning Methodology

This document outlines the planning approach, decision-making criteria, and preparation activities for the ESXi to AHV migration.

### Planning Objectives

The migration plan was designed to achieve the following goals:

- Minimize business disruption
- Maintain data integrity
- Reduce migration risk through phased execution
- Preserve existing network and application configurations
- Establish repeatable migration procedures

## Migration Approach Selection

## Executive Planning Summary

After evaluating multiple migration strategies, a phased migration approach was selected as the optimal balance between risk, downtime, operational complexity, and project duration.

The migration will be executed across three controlled waves, beginning with non-critical systems and concluding with business-critical workloads.

### Options Considered

| Approach | Description | Pros | Cons | Selected |
|----------|-------------|------|------|----------|
| Big Bang | Migrate all VMs in one weekend | Faster completion | High risk, limited rollback | ❌ No |
| Phased/Wave | Migrate in groups by priority | Lower risk, controlled | Longer duration | ✅ Yes |
| Parallel Run | Run both platforms simultaneously | Zero risk | Double infrastructure cost | ❌ No |
| Greenfield | Rebuild all VMs from scratch | Clean environment | Too much effort, high risk | ❌ No |

**Decision:** Phased migration with 3 waves based on workload criticality

### Wave Strategy

**Wave 1: Low-Priority Workloads (Development/Test)**
- **VM Count:** 30
- **Duration:** 2 weeks
- **Rationale:** Low business impact, validate migration process

**Wave 2: Medium-Priority Workloads (File/Web Servers)**
- **VM Count:** 40
- **Duration:** 2 weeks
- **Rationale:** Moderate usage, acceptable downtime windows

**Wave 3: High-Priority/Critical Workloads (AD, SQL, Email)**
- **VM Count:** 50
- **Duration:** 2 weeks
- **Rationale:** Requires careful planning, minimal downtime

## VM Prioritization Matrix

### Criticality Assessment Criteria

VMs categorized by:
1. **Business Impact:** Revenue-generating, customer-facing, internal operations
2. **Downtime Tolerance:** Minutes, hours, or can be offline
3. **Dependencies:** Standalone vs tightly coupled with other services
4. **Complexity:** Simple web server vs clustered database

### Priority Tiers

**Tier 1 - Critical (Migrate Last, Waves 3)**

| VM Category | Count | Max Downtime | Migration Window |
|-------------|-------|--------------|------------------|
| Active Directory/DNS | 4 | 15 minutes | Saturday 2 AM - 4 AM |
| SQL Production Servers | 12 | 30 minutes | Saturday 11 PM - 2 AM |
| Email Server | 2 | 1 hour | Saturday 10 PM - 12 AM |
| Primary File Server | 3 | 1 hour | Sunday 12 AM - 3 AM |

**Tier 2 - High Priority (Wave 2)**

| VM Category | Count | Max Downtime | Migration Window |
|-------------|-------|--------------|------------------|
| Application Servers | 20 | 2 hours | Weeknight 8 PM - 11 PM |
| Web Servers | 15 | 2 hours | Weeknight 9 PM - 12 AM |
| Secondary File Servers | 5 | 4 hours | Weekend daytime |

**Tier 3 - Low Priority (Wave 1)**

| VM Category | Count | Max Downtime | Migration Window |
|-------------|-------|--------------|------------------|
| Development VMs | 15 | Anytime | Weekday daytime |
| Test Environments | 10 | Anytime | Weekday daytime |
| Monitoring/Tools | 5 | 4 hours | Weekend |

## Dependency Mapping

### Application Dependencies

**Active Directory (Critical Path):**
```
AD Domain Controllers
    ↓
DNS Services
    ↓
SQL Servers, File Servers, Email
    ↓
Application Servers
    ↓
Web Servers
```

**Migration Order:** Migrate AD/DNS first, then dependent services

**SQL Server AlwaysOn Availability Group:**
```
SQL-PROD-01 (Primary) ← Synchronous Replication → SQL-PROD-02 (Secondary)
    ↓
Application Servers (connect via listener)
```

**Migration Strategy:** 
1. Migrate SQL-PROD-02 (secondary)
2. Failover to SQL-PROD-02
3. Migrate SQL-PROD-01 (now secondary)
4. Failback to SQL-PROD-01

## Resource Planning

## Migration Success Factors

The following factors are critical to project success:

- Accurate dependency mapping
- Successful pilot migration
- Backup verification before each wave
- Application owner participation
- Change management approval
- Rollback readiness

### Nutanix Cluster Capacity

**Available Resources:**

| Resource | Total Capacity | Reserved (HA) | Usable | Current ESXi Usage | Headroom |
|----------|---------------|---------------|--------|-------------------|----------|
| vCPU | 192 cores | 48 cores | 144 cores | 98 cores | 46 cores (32%) |
| Memory | 1.5 TB | 384 GB | 1.14 TB | 720 GB | 420 GB (37%) |
| Storage | 60 TB usable | 6 TB | 54 TB | 32.5 TB | 21.5 TB (40%) |

**Capacity Planning:**
- All 120 VMs fit within available resources
- 30%+ headroom maintained for growth
- No VM rightsizing required pre-migration

### Storage Migration Sizing

**Data Transfer Estimates:**

| VM Category | Count | Avg Size | Total Data | Est. Transfer Time |
|-------------|-------|----------|------------|-------------------|
| Small VMs (<100 GB) | 45 | 60 GB | 2.7 TB | 30-45 min each |
| Medium VMs (100-500 GB) | 50 | 250 GB | 12.5 TB | 1.5-2 hours each |
| Large VMs (500GB-1TB) | 15 | 750 GB | 11.25 TB | 3-4 hours each |
| XL VMs (>1TB) | 10 | 1.5 TB | 15 TB | 5-6 hours each |

**Total Data to Migrate:** ~42 TB  
**Network Bandwidth:** 10 Gbps dedicated migration network  
**Theoretical Max Throughput:** 1.25 GB/s = 4.5 TB/hour

## Network Planning

### VLAN Configuration

**Nutanix Network Setup:**

| VLAN | Name | Purpose | IP Range | Notes |
|------|------|---------|----------|-------|
| 10 | Management | AHV host mgmt, CVM | 192.168.10.0/24 | Existing, extend to Nutanix |
| 20 | Production | Production VMs | 10.10.20.0/24 | Migrate existing IPs |
| 30 | DMZ | Public services | 10.10.30.0/24 | Maintain current config |
| 40 | Storage | Not used on AHV | N/A | Nutanix internal storage |
| 50 | Backup | Backup network | 192.168.50.0/24 | Extend to AHV |
| 60 | Development | Dev/Test VMs | 10.10.60.0/24 | Extend to AHV |

### IP Address Retention

**Strategy:** Retain existing IP addresses for all VMs

**Process:**
1. Document IP/MAC mappings from vCenter
2. Configure DHCP reservations or static IPs on Nutanix
3. Power off source VM
4. Migrate to AHV with same IP
5. Update DNS if needed

**DNS Updates:**
- No DNS changes needed (IPs stay same)
- Update DNS only if VM name changes
- Verify DNS resolution post-migration

## Migration Tool Configuration

### Nutanix Move Setup

**Move VM Appliance:**
- Deployed on Nutanix cluster
- 4 vCPU, 8 GB RAM
- Connected to management network

**Source Configuration:**
- Add vCenter Server as source
- Credentials: Read-only service account
- Connection validated

**Target Configuration:**
- Add Nutanix cluster as target
- Connection via Prism Element
- Network mapping configured

**Network Mapping:**

| Source (ESXi) | Target (AHV) |
|---------------|--------------|
| Production (VLAN 20) | Production (VLAN 20) |
| DMZ (VLAN 30) | DMZ (VLAN 30) |
| Development (VLAN 60) | Development (VLAN 60) |
| Backup (VLAN 50) | Backup (VLAN 50) |

## Migration Windows

### Scheduled Maintenance Windows

**Wave 1 - Development/Test VMs:**
- **Window:** Weekdays 9 AM - 5 PM (business hours acceptable for dev)
- **Duration:** 2-3 hours per batch
- **Frequency:** Daily migrations

**Wave 2 - Medium Priority:**
- **Window:** Weeknights 8 PM - 12 AM
- **Duration:** 3-4 hours per batch
- **Frequency:** Tuesday/Wednesday nights

**Wave 3 - Critical Workloads:**
- **Window:** Saturday nights 10 PM - Sunday 6 AM
- **Duration:** 6-8 hours per batch
- **Frequency:** Weekly (one batch per weekend)

### Change Management

**Change Request Process:**
- Submit change 5 business days before migration
- Include: VM list, downtime estimate, rollback plan
- Approval required from: IT Manager, Application Owner
- Communicate to stakeholders 72 hours before

## Pre-Migration Preparation

### VM Preparation Checklist

**30 Days Before Migration:**
- [ ] Complete VM inventory with dependencies
- [ ] Document application configurations
- [ ] Identify OS compatibility issues
- [ ] Update VMware Tools to latest version
- [ ] Clean up snapshots (delete old snapshots)
- [ ] Verify VM is backed up successfully

**7 Days Before Migration:**
- [ ] Application owner notification
- [ ] Verify backup completed within 24 hours
- [ ] Test application in current state
- [ ] Document performance baselines
- [ ] Confirm maintenance window approval
- [ ] Prepare rollback procedures

**24 Hours Before Migration:**
- [ ] Final backup verification
- [ ] Notify helpdesk of planned downtime
- [ ] Stage Nutanix Move migration plan
- [ ] Confirm network team availability
- [ ] Review runbook with team

### Nutanix Cluster Preparation

- [ ] Prism Central configured and accessible
- [ ] All VLANs created and tested
- [ ] Storage containers created with appropriate sizing
- [ ] Nutanix Move appliance deployed
- [ ] vCenter connection validated in Move
- [ ] Network mapping configured
- [ ] Test migration completed successfully (pilot VM)

## Communication Plan

## Risk Mitigation Strategy

| Risk | Mitigation |
|--------|--------|
| Extended downtime | Pilot migrations and staged cutovers |
| Network misconfiguration | Pre-migration validation |
| Application failure | Owner testing and sign-off |
| Data corruption | Backup verification and Nutanix Move validation |
| Migration delays | Reserved maintenance windows |

### Stakeholder Communication

**Project Kickoff (Week 0):**
- Executive summary to IT leadership
- Detailed plan to technical teams
- Timeline to application owners

**Weekly Updates (During Migration):**
- Migration progress report
- Upcoming week's schedule
- Issues and resolutions

**Pre-Migration Notifications:**
- Email to application owners (72 hours before)
- Reminder email (24 hours before)
- Final notification (4 hours before)

**Post-Migration:**
- Success confirmation (within 2 hours)
- Issues/rollbacks reported immediately
- Weekly summary to stakeholders

### Escalation Path

**Level 1:** Migration Team Lead
**Level 2:** Senior Systems Engineer  
**Level 3:** IT Manager  
**Level 4:** IT Director  

**Vendor Escalation:**
- Nutanix Support: 24/7 hotline for critical issues
- VMware Support: Available for ESXi-related problems

## Training and Knowledge Transfer

### Team Training

**Nutanix AHV Training:**
- Prism Central administration
- VM lifecycle management
- Basic troubleshooting
- Backup and recovery with AHV

**Nutanix Move Training:**
- Migration planning
- Executing migrations
- Monitoring and validation
- Rollback procedures

**Timeline:** 2 weeks before Wave 1 begins

### Documentation Requirements

- Migration runbooks (step-by-step guides)
- Network configuration diagrams
- Rollback procedures
- Lessons learned after each wave
- Final project report

---

*Document Version: 1.0*  
*Last Updated: May 2026*  
*Author: Lokesh Yadav*
