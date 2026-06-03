# Migration Execution Steps

## Step-by-Step Migration Guide

### Purpose

This runbook provides standardized procedures for executing VMware ESXi to Nutanix AHV migrations while minimizing downtime, ensuring data integrity, and maintaining rollback capability.

All migration activities must follow approved change management processes and maintenance windows.

## Pre-Migration Validation

### 1. VM Readiness Check

**Reference Script:** pre-migration-check.ps1

**Manual Checks:**

```powershell
# Connect to vCenter
Connect-VIServer -Server vcenter.company.local

# Get VM details
$vm = Get-VM -Name "VM-Name"

# Check VM configuration
$vm | Select Name, PowerState, NumCpu, MemoryGB, 
    @{N="ProvisionedSpaceGB";E={[math]::Round($_.ProvisionedSpaceGB,2)}},
    @{N="UsedSpaceGB";E={[math]::Round($_.UsedSpaceGB,2)}}

# Check VMware Tools status
$vm | Get-View | Select Name, 
    @{N="ToolsStatus";E={$_.Guest.ToolsStatus}},
    @{N="ToolsVersion";E={$_.Guest.ToolsVersion}}

# Check for snapshots
$vm | Get-Snapshot

# Verify backup status
# (Check in Veeam console - manual verification)
```

**Validation Checklist:**

- [ ] VM is powered on and accessible
- [ ] VMware Tools installed and running
- [ ] No active snapshots (or documented reason)
- [ ] Backup completed within 24 hours
- [ ] Sufficient storage on target Nutanix cluster
- [ ] Network mapping verified
- [ ] Application owner notified and acknowledged

### 2. Nutanix Move Configuration Verification

**Access Nutanix Move:**
- URL: https://nutanix-move-ip:8443
- Login with Prism credentials

**Verify Configuration:**

- [ ] vCenter connection active (Status: Green)
- [ ] Nutanix target cluster available
- [ ] Network mapping configured correctly
- [ ] No pending migrations in "Failed" state

## Migration Execution Process

### Phase 1: Initial Data Seeding (VM Remains Running)

**Step 1: Create Migration Plan**

1. Log into Nutanix Move web interface
2. Click **+ Create Migration Plan**
3. Enter plan name: `Wave-X-Batch-Y-[Date]`
4. Select source: vCenter Server
5. Select target: Nutanix Cluster
6. Click **Proceed**

**Step 2: Select VMs**

1. Browse VM inventory
2. Select VMs for this batch (max 5 VMs per batch recommended)
3. Click **Next**

**Step 3: Configure Migration Settings**

| Setting | Value | Notes |
|---------|-------|-------|
| Target Container | Production-Container | Match workload type |
| Network Mapping | Verify correct VLAN | Critical - double-check |
| Schedule | On-Demand | Manual trigger for cutover |
| Preparation | Enable | Creates target VM structure |

**Step 4: Review and Save**

1. Review configuration summary
2. Verify VM list, network, storage
3. Click **Save Migration Plan**

**Step 5: Start Seeding**

1. Select migration plan
2. Click **Start Preparation**
3. Monitor progress in Move dashboard

**Seeding Process:**
- Source VM remains powered on and operational
- Move copies VM disk data in the background
- Application continues running (zero downtime during seeding)
- Duration: 1-6 hours depending on VM size

**Monitoring Seeding:**
```
Status Updates:
- Initializing (5-10 min)
- Seeding Data (1-6 hours)
- Seeding Complete - Ready for Cutover
```

### Phase 2: Final Cutover (Downtime Window)

**Step 1: Pre-Cutover Validation**

- [ ] Seeding 100% complete
- [ ] Application team on standby
- [ ] Change management approval confirmed
- [ ] Rollback procedure reviewed
- [ ] Stakeholders notified

**Step 2: Initiate Cutover**

**Timing:** Start of approved maintenance window

1. In Nutanix Move, select migration plan
2. Click **Cutover**
3. Confirm cutover action

**Automated Steps by Move:**

1. **Final Sync Preparation**
   - Duration: 2-5 minutes
   - Move prepares for final data sync

2. **Graceful Shutdown of Source VM**
   - Move triggers VMware Tools shutdown
   - VM shuts down cleanly
   - If shutdown fails after 5 min, forced power-off
   - **Downtime begins here**

3. **Final Data Sync**
   - Duration: 5-30 minutes (only changed blocks)
   - Move copies any data written since seeding
   - Ensures data consistency

4. **VM Conversion**
   - Duration: 5-10 minutes
   - Move converts VMDK to Nutanix format
   - Applies network configuration
   - Installs Nutanix Guest Tools

5. **Power On Target VM**
   - VM boots on Nutanix AHV
   - Network connectivity established
   - **Downtime ends if successful**

**Typical Downtime:** 20-45 minutes depending on VM size

### Phase 3: Post-Migration Validation

**Step 1: Initial Health Check (5 minutes)**

**Access Prism Element:**
```
1. Navigate to VM dashboard
2. Verify VM status: Running
3. Check network connectivity: IP address assigned
4. Verify Nutanix Guest Tools status: Running
```

**Step 2: Application Validation (15-30 minutes)**

**Windows VMs:**

```powershell
# RDP into the VM
mstsc /v:VM-IP-Address

# Verify services
Get-Service | Where-Object {$_.StartType -eq "Automatic" -and $_.Status -ne "Running"}

# Check network connectivity
Test-NetConnection -ComputerName gateway-ip
Test-NetConnection -ComputerName domain-controller -Port 389

# Verify disk drives
Get-Volume | Select DriveLetter, FileSystemLabel, HealthStatus, SizeRemaining

# Check event logs for errors
Get-EventLog -LogName System -Newest 50 -EntryType Error
Get-EventLog -LogName Application -Newest 50 -EntryType Error
```

**Linux VMs:**

```bash
# SSH into the VM
ssh user@VM-IP-Address

# Check services
systemctl list-units --type=service --state=failed

# Network connectivity
ping -c 4 gateway-ip
ping -c 4 dns-server

# Disk space
df -h

# Check system logs
journalctl -p err -n 50
```

**Step 3: Application-Specific Testing**

**Active Directory Domain Controller:**
```powershell
# Verify AD replication
repadmin /replsummary
dcdiag /test:DNS
dcdiag /test:Replications

# Test LDAP
nltest /dsgetdc:domain.local

# Verify SYSVOL replication
dfsrdiag replicationstate /all
```

**SQL Server:**
```sql
-- Connect via SQL Server Management Studio
-- Verify databases online
SELECT name, state_desc, recovery_model_desc 
FROM sys.databases

-- Check SQL Agent jobs
EXEC sp_help_job

-- Verify AlwaysOn AG status (if applicable)
SELECT * FROM sys.dm_hadr_availability_group_states
```

**File Server:**
```powershell
# Verify shares accessible
Get-SmbShare

# Test file access from client
# From client workstation:
Test-Path \\fileserver\share
dir \\fileserver\share
```

**Web Server:**
```bash
# Check web service status
systemctl status httpd   # or nginx/apache2

# Test HTTP response
curl -I http://localhost

# Verify from external client
# Browser: http://webserver-ip
```

**Step 4: Performance Validation**

**Compare Against Baseline:**

| Metric | Baseline (ESXi) | Current (AHV) | Status |
|--------|----------------|---------------|--------|
| CPU Utilization | 35% | 32% | ✅ Normal |
| Memory Usage | 6.2 GB | 6.1 GB | ✅ Normal |
| Disk Latency | 8 ms | 7 ms | ✅ Improved |
| Network Throughput | 120 Mbps | 125 Mbps | ✅ Normal |

**Prism Metrics Check:**
```
1. Select VM in Prism
2. View performance tab
3. Monitor for 15-30 minutes:
   - CPU usage stable
   - Memory usage normal
   - Disk IOPS within expected range
   - Network throughput normal
```

**Step 5: User Acceptance Testing**

- [ ] Application owner performs functional testing
- [ ] End users confirm access and functionality
- [ ] No performance degradation reported
- [ ] Sign-off received from application owner

### Phase 4: Post-Cutover Cleanup

**Step 1: Verify Source VM State**

```powershell
# Connect to vCenter
Connect-VIServer -Server vcenter.company.local

# Verify source VM is powered off
Get-VM -Name "VM-Name" | Select Name, PowerState

# Expected: PowerState = PoweredOff
```

**Keep source VM powered off for 7 days** (retention period)

**Step 2: Update Documentation**

- [ ] Update asset inventory (CMDB)
- [ ] Update network documentation
- [ ] Note VM now on Nutanix platform
- [ ] Update runbooks/SOPs

**Step 3: Update Monitoring**

- [ ] Add VM to Nutanix monitoring
- [ ] Remove from VMware-specific monitoring
- [ ] Verify alerting configured
- [ ] Update backup jobs

**Step 4: Migration Plan Status**

In Nutanix Move:
- Migration plan shows "Succeeded"
- Review migration logs
- Archive logs for reporting

## Rollback Procedure

## Migration Success Criteria

A migration is considered successful when:

- VM boots successfully on AHV
- Network connectivity is validated
- Application services are operational
- Performance remains within baseline thresholds
- Application owner sign-off is received
- No critical errors remain unresolved

**Trigger Conditions:**
- VM fails to boot after 3 attempts
- Critical application non-functional
- Data integrity issues detected
- Performance degradation >30%

**Rollback Steps:**

**Step 1: Immediate Actions (5 minutes)**

1. Power off VM on Nutanix AHV (if running)
```
Prism > Select VM > Power Off
```

2. Notify stakeholders of rollback decision
3. Document failure symptoms

**Step 2: Restore Source VM (10 minutes)**

```powershell
# Power on source VM in vCenter
Get-VM -Name "VM-Name" | Start-VM

# Wait for boot (2-3 minutes)
# Verify VM accessible
Test-NetConnection -ComputerName VM-IP -Port 3389  # RDP
# or
Test-NetConnection -ComputerName VM-IP -Port 22     # SSH
```

**Step 3: Restore Network Connectivity**

- If IP conflict exists, manually correct
- Verify DNS resolution
- Test application connectivity

**Step 4: Verify Functionality**

- Application owner validates functionality
- Users confirm access restored
- Document any data loss window

**Step 5: Post-Rollback Analysis**

- Root cause analysis meeting
- Update migration runbook
- Schedule retry (if applicable)

**Typical Rollback Time:** 15-30 minutes

## Batch Migration Strategy

## Lessons Learned Template

Capture the following after each migration batch:

- Planned downtime
- Actual downtime
- Issues encountered
- Resolution steps
- Performance observations
- Recommendations for future waves

**Recommended Batch Size:**
- **Small VMs (<100 GB):** 5 VMs per batch
- **Medium VMs (100-500 GB):** 3 VMs per batch
- **Large VMs (>500 GB):** 1-2 VMs per batch

**Parallel Migrations:**
- Maximum 2 batches running simultaneously
- Monitor network bandwidth utilization
- Avoid migrating interdependent VMs simultaneously

**Daily Migration Capacity:**
- Wave 1 (Dev/Test): 10-15 VMs per day
- Wave 2 (Medium Priority): 6-8 VMs per day
- Wave 3 (Critical): 3-5 VMs per weekend

## Troubleshooting Common Issues

### Issue 1: VM Fails to Power On After Migration

**Symptoms:** VM stuck at BIOS/UEFI screen or boot loop

**Resolution:**
```
1. Check boot order in VM configuration
2. Verify all virtual disks attached
3. Review VM logs in Prism
4. If UEFI issue: Convert to BIOS mode or vice versa
5. Last resort: Rollback and retry
```

### Issue 2: Network Connectivity Lost

**Symptoms:** VM boots but no network access

**Resolution:**
```
1. Verify VLAN assignment in Prism
2. Check VM network adapter settings
3. Verify IP configuration inside VM (DHCP or static)
4. Test connectivity: ping gateway, DNS
5. Check for duplicate IP addresses
6. Restart network service in VM
```

### Issue 3: Application Service Won't Start

**Symptoms:** VM boots, network OK, but application fails

**Resolution:**
```
1. Check Windows Event Viewer / Linux logs
2. Verify service dependencies running
3. Check for licensing issues (hardware change detected)
4. Review application configuration files
5. Restart dependent services in correct order
6. Contact application vendor if needed
```

### Issue 4: Poor Performance After Migration

**Symptoms:** VM slower than on ESXi

**Resolution:**
```
1. Verify Nutanix Guest Tools installed
2. Check CPU/Memory allocation (same as ESXi?)
3. Review storage container configuration
4. Check for VM resource contention
5. Compare Prism metrics to ESXi baseline
6. Allow 24 hours for caching to optimize
```

---

*Document Version: 1.0*  
*Last Updated: May 2026*  
*Author: Lokesh Yadav*
