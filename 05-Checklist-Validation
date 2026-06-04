# Validation Checklist

## Comprehensive Validation Procedures

### Validation Objectives

The purpose of validation is to confirm that migrated workloads remain functional, performant, secure, and fully operational following migration to Nutanix AHV.

Validation activities are performed before migration, during cutover, after migration, and at project closure.

## Pre-Migration Validation

## Validation Framework

Validation activities are divided into four stages:

1. Pre-Migration Validation
2. Migration Execution Validation
3. Post-Migration Validation
4. Project Closure Validation

Each stage must be completed successfully before progression to the next phase.

### VM Assessment Checklist

**VM Configuration:**
- [ ] VM name documented
- [ ] vCPU count: _____ cores
- [ ] Memory allocation: _____ GB
- [ ] Total disk space: _____ GB
- [ ] Network adapter count: _____
- [ ] Operating system: _____
- [ ] OS version verified compatible with AHV

**VMware Tools:**
- [ ] VMware Tools status: Running
- [ ] VMware Tools version: _____
- [ ] VMware Tools up-to-date (or documented reason)

**Snapshots:**
- [ ] Current snapshots: None OR
- [ ] Snapshots documented with business justification
- [ ] Snapshot removal approved (if needed)

**Backup Verification:**
- [ ] Last successful backup: _____ (date/time)
- [ ] Backup within 24 hours: Yes/No
- [ ] Test restore validated: Yes/No
- [ ] Backup retention extended for migration period: Yes/No

**Application Dependencies:**
- [ ] Application dependencies mapped
- [ ] Database connections documented
- [ ] File share dependencies noted
- [ ] External service integrations listed

**Performance Baseline:**
- [ ] CPU utilization baseline: _____% (30-day avg)
- [ ] Memory utilization baseline: _____% (30-day avg)
- [ ] Disk IOPS baseline: _____ IOPS
- [ ] Network throughput baseline: _____ Mbps
- [ ] Application response time baseline: _____ ms

### Network Configuration Checklist

**IP Addressing:**
- [ ] Current IP address: _____
- [ ] IP allocation type: Static / DHCP
- [ ] If static: Gateway: _____
- [ ] If static: DNS servers: _____
- [ ] If DHCP: DHCP reservation configured on target: Yes/No

**VLAN Assignment:**
- [ ] Current VLAN: _____
- [ ] Target VLAN created on Nutanix: Yes/No
- [ ] VLAN mapping verified in Nutanix Move: Yes/No

**DNS Configuration:**
- [ ] DNS A record exists: Yes/No
- [ ] DNS A record IP: _____
- [ ] PTR (reverse DNS) record exists: Yes/No
- [ ] DNS update required post-migration: Yes/No

**Firewall Rules:**
- [ ] Inbound rules documented
- [ ] Outbound rules documented
- [ ] Firewall rules will remain valid post-migration: Yes/No

### Nutanix Target Environment Checklist

**Cluster Capacity:**
- [ ] Available vCPU cores: _____ cores
- [ ] Available memory: _____ GB
- [ ] Available storage: _____ TB
- [ ] Sufficient resources for this VM: Yes/No

**Storage Configuration:**
- [ ] Target storage container: _____
- [ ] Container capacity: _____ TB
- [ ] Container usage: _____ TB
- [ ] Sufficient space for VM: Yes/No

**Network Configuration:**
- [ ] Target VLAN configured: Yes/No
- [ ] VLAN ID matches source: Yes/No
- [ ] VLAN tested and operational: Yes/No

**Nutanix Move Readiness:**
- [ ] Move appliance accessible: Yes/No
- [ ] vCenter connection active: Yes/No
- [ ] Target cluster visible in Move: Yes/No
- [ ] Network mapping configured: Yes/No

### Stakeholder Approval Checklist

**Communication:**
- [ ] Application owner notified (72 hours): Date: _____
- [ ] Reminder sent (24 hours): Date: _____
- [ ] Helpdesk notified of maintenance window: Yes/No
- [ ] End users notified (if required): Yes/No

**Change Management:**
- [ ] Change request submitted: Ticket #: _____
- [ ] Change request approved: Yes/No
- [ ] Maintenance window scheduled: Date/Time: _____
- [ ] Rollback procedure documented: Yes/No

**Team Readiness:**
- [ ] Migration engineer available: _____
- [ ] Network engineer on standby: _____
- [ ] Application owner available for testing: _____
- [ ] Escalation contacts confirmed: Yes/No

---

## Migration Execution Checklist

### Pre-Cutover Checklist (T-1 Hour)

- [ ] All pre-migration validation complete
- [ ] Seeding 100% complete (Nutanix Move status)
- [ ] Final backup verified: Date/Time: _____
- [ ] Application owner on standby: Confirmed via: _____
- [ ] Rollback procedure reviewed: Yes
- [ ] Downtime notification sent: Date/Time: _____

**Go/No-Go Decision:**
- [ ] All checklist items complete: Proceed / Abort
- [ ] Decision maker approval: Name: _____ Date/Time: _____

### Cutover Execution Checklist

**Step 1: Initiate Cutover**
- [ ] Cutover started in Nutanix Move: Time: _____
- [ ] Source VM shutdown initiated: Time: _____
- [ ] Source VM powered off: Time: _____
- [ ] **Downtime window begins: Time: _____**

**Step 2: Monitor Migration**
- [ ] Final data sync progress: _____% (monitor until 100%)
- [ ] VM conversion in progress: Status: _____
- [ ] Estimated completion time: _____

**Step 3: Target VM Boot**
- [ ] Target VM powered on: Time: _____
- [ ] VM boot successful: Yes/No
- [ ] **Downtime window ends: Time: _____**
- [ ] **Total downtime: _____ minutes**

### Immediate Post-Migration Checklist (T+15 Minutes)

**VM Status in Prism:**
- [ ] VM status: Running
- [ ] Power state: On
- [ ] IP address assigned: _____
- [ ] Nutanix Guest Tools status: Running / Installing / Not Installed

**Network Connectivity:**
- [ ] Ping gateway successful: Yes/No
- [ ] Ping DNS server successful: Yes/No
- [ ] DNS resolution working: Yes/No
- [ ] External connectivity (internet): Yes/No

**Service Availability:**
- [ ] RDP accessible (Windows): Yes/No OR
- [ ] SSH accessible (Linux): Yes/No
- [ ] Application services started: Yes/No (list services checked)

---

## Post-Migration Validation

### Windows VM Validation Checklist

**Operating System Health:**
- [ ] Windows login successful: Yes/No
- [ ] Event Viewer - System errors: None / Documented: _____
- [ ] Event Viewer - Application errors: None / Documented: _____
- [ ] Automatic services running: All / Exceptions: _____

**Disk Configuration:**
- [ ] All drive letters present: C:, D:, E:, etc. (list all)
- [ ] Disk space matches source: Yes/No
- [ ] Disk health status: Healthy

**Network Configuration:**
```powershell
# Run and document results
ipconfig /all
# Verify:
```
- [ ] IP address correct: _____
- [ ] Subnet mask correct: _____
- [ ] Gateway correct: _____
- [ ] DNS servers correct: _____
- [ ] WINS servers (if used): _____

**Active Directory (if domain-joined):**
```powershell
nltest /sc_query:domain.local
```
- [ ] Secure channel to domain: OK / Failed
- [ ] Domain connectivity: Yes/No
- [ ] LDAP queries working: Yes/No
- [ ] Group Policy updating: Yes/No

**Performance Check:**
```powershell
Get-Counter '\Processor(_Total)\% Processor Time'
Get-Counter '\Memory\% Committed Bytes In Use'
```
- [ ] CPU utilization normal: _____% (compare to baseline)
- [ ] Memory utilization normal: _____% (compare to baseline)
- [ ] Disk response time normal: _____ ms

### Linux VM Validation Checklist

**Operating System Health:**
- [ ] SSH login successful: Yes/No
- [ ] System logs reviewed: `journalctl -p err -n 50`
- [ ] Failed services: None / Documented: _____

**Disk Configuration:**
```bash
df -h
```
- [ ] All filesystems mounted: Yes/No (list: /, /home, /var, etc.)
- [ ] Disk space matches source: Yes/No
- [ ] Filesystem errors: None / Documented: _____

**Network Configuration:**
```bash
ip addr show
ip route show
cat /etc/resolv.conf
```
- [ ] IP address correct: _____
- [ ] Gateway correct: _____
- [ ] DNS servers correct: _____
- [ ] Hostname correct: _____

**Service Validation:**
```bash
systemctl list-units --type=service --state=running
systemctl list-units --type=service --state=failed
```
- [ ] Expected services running: Yes/No (list checked services)
- [ ] No unexpected failed services: Yes/No

**Performance Check:**
```bash
top -bn1 | head -20
free -h
iostat -x 1 5
```
- [ ] CPU load average: _____ (compare to baseline)
- [ ] Memory usage: _____% (compare to baseline)
- [ ] Disk I/O normal: Yes/No

### Application-Specific Validation

**Active Directory Domain Controller:**
- [ ] AD replication: `repadmin /replsummary` - OK
- [ ] SYSVOL replication: `dfsrdiag replicationstate` - OK
- [ ] DNS service: `nslookup domain.local` - Resolves
- [ ] LDAP service: `nltest /dsgetdc:domain.local` - OK
- [ ] Domain controller diagnostics: `dcdiag` - Passed

**SQL Server:**
```sql
-- Run queries and document
SELECT name, state_desc FROM sys.databases
EXEC sp_help_job
SELECT @@SERVERNAME
```
- [ ] All databases online: Yes/No
- [ ] SQL Agent running: Yes/No
- [ ] Scheduled jobs enabled: Yes/No
- [ ] AlwaysOn AG status (if applicable): Healthy / N/A
- [ ] Test query execution: Success / Failed
- [ ] Application connectivity: Tested / Pending

**File Server:**
- [ ] SMB shares accessible: `Get-SmbShare` - All present
- [ ] File share permissions intact: Verified
- [ ] DFS namespace working (if used): Yes/No/N/A
- [ ] Client access test: `\\server\share` - Success
- [ ] Large file transfer test: Success / Pending

**Web Server (IIS/Apache/Nginx):**
- [ ] Web service running: Yes/No
- [ ] Website accessible locally: `curl http://localhost`
- [ ] Website accessible externally: Browser test - Success
- [ ] Application pool status (IIS): All started
- [ ] SSL certificate valid: Yes/No/N/A
- [ ] Backend database connectivity: Tested / Pending

**Exchange Server:**
- [ ] Exchange services running: All / Exceptions: _____
- [ ] Mailbox database mounted: Yes/No
- [ ] OWA accessible: Yes/No
- [ ] MAPI connectivity: Outlook test - Success
- [ ] Email flow test: Send/receive - Success
- [ ] Database replication (if DAG): Healthy / N/A

### Performance Baseline Comparison

## Monitoring Period

Following migration, workloads should be monitored for a minimum of 24-48 hours before final closure.

Monitoring should focus on:

- CPU utilization
- Memory utilization
- Storage latency
- Network throughput
- Application response times
- User-reported issues

**VM Resource Utilization:**

| Metric | ESXi Baseline | AHV Current | Delta | Status |
|--------|---------------|-------------|-------|--------|
| CPU Avg | _____% | _____% | _____% | ✅ ⚠️ ❌ |
| CPU Peak | _____% | _____% | _____% | ✅ ⚠️ ❌ |
| Memory Avg | _____% | _____% | _____% | ✅ ⚠️ ❌ |
| Disk Read IOPS | _____ | _____ | _____ | ✅ ⚠️ ❌ |
| Disk Write IOPS | _____ | _____ | _____ | ✅ ⚠️ ❌ |
| Disk Latency | _____ ms | _____ ms | _____ ms | ✅ ⚠️ ❌ |
| Network TX | _____ Mbps | _____ Mbps | _____ Mbps | ✅ ⚠️ ❌ |
| Network RX | _____ Mbps | _____ Mbps | _____ Mbps | ✅ ⚠️ ❌ |

**Status Legend:**
- ✅ Green: Within ±10% of baseline
- ⚠️ Yellow: ±10-30% variance - investigate
- ❌ Red: >30% variance - action required

**Application Response Time:**

| Test | ESXi Baseline | AHV Current | Delta | Status |
|------|---------------|-------------|-------|--------|
| Web page load | _____ ms | _____ ms | _____ ms | ✅ ⚠️ ❌ |
| Database query | _____ ms | _____ ms | _____ ms | ✅ ⚠️ ❌ |
| File access | _____ ms | _____ ms | _____ ms | ✅ ⚠️ ❌ |
| API response | _____ ms | _____ ms | _____ ms | ✅ ⚠️ ❌ |

### User Acceptance Testing

**Application Owner Sign-Off:**

- [ ] Application functionality verified: Date: _____ By: _____
- [ ] No performance degradation reported: Yes/No
- [ ] End user testing completed: Yes/No/N/A
- [ ] Issues identified: None / Documented: _____
- [ ] **Migration approved for production use: Yes/No**
- [ ] **Sign-off signature: _____ Date: _____**

---

## Wave Completion Validation

## Validation Success Criteria

A migration is considered validated when:

- Infrastructure services are operational
- Network connectivity is verified
- Application functionality is confirmed
- Performance remains within acceptable thresholds
- User acceptance testing is completed
- Required stakeholder approvals are obtained

### Batch Summary

**Migration Batch:** Wave ___ - Batch ___ - Date: _____

**VMs in This Batch:**

| VM Name | Status | Downtime | Issues | Sign-Off |
|---------|--------|----------|--------|----------|
| VM-01 | ✅ ⚠️ ❌ | ___ min | None / ___ | ✅ ⏳ |
| VM-02 | ✅ ⚠️ ❌ | ___ min | None / ___ | ✅ ⏳ |
| VM-03 | ✅ ⚠️ ❌ | ___ min | None / ___ | ✅ ⏳ |
| VM-04 | ✅ ⚠️ ❌ | ___ min | None / ___ | ✅ ⏳ |
| VM-05 | ✅ ⚠️ ❌ | ___ min | None / ___ | ✅ ⏳ |

**Batch Statistics:**
- Total VMs: _____
- Successful: _____
- Rolled back: _____
- Pending: _____
- Success rate: _____%
- Average downtime: _____ minutes

### Wave Completion Checklist

- [ ] All VMs in wave migrated: Yes / Exceptions: _____
- [ ] No outstanding critical issues: Yes / Issues: _____
- [ ] Performance monitoring shows stable metrics: Yes/No
- [ ] User acceptance sign-offs received: ____/____
- [ ] Source VMs confirmed powered off: Yes/No
- [ ] Migration logs archived: Location: _____
- [ ] Documentation updated: Yes/No
- [ ] Lessons learned documented: Yes/No

**Wave Sign-Off:**
- [ ] Technical lead approval: Name: _____ Date: _____
- [ ] IT manager approval: Name: _____ Date: _____

---

## Final Project Validation

## Audit and Compliance Verification

Before project closure:

- Migration records archived
- Change tickets closed
- Approval records retained
- Validation evidence stored
- Migration logs archived
- Rollback records documented (if applicable)

### Project Completion Criteria

**Migration Metrics:**
- [ ] Total VMs migrated: ____/120 (100%)
- [ ] Overall success rate: ____% (target: >95%)
- [ ] Average downtime per VM: _____ min (target: <60 min)
- [ ] Rollbacks required: _____ (target: <5%)

**Infrastructure Status:**
- [ ] All VMs operational on Nutanix AHV: Yes/No
- [ ] No performance degradation vs ESXi baseline: Yes/No
- [ ] Nutanix cluster health: Healthy / Issues: _____
- [ ] ESXi environment decommissioned: Yes/No / Planned: _____

**Business Outcomes:**
- [ ] Zero data loss incidents: Yes/No
- [ ] SLA adherence: _____% (target: 100%)
- [ ] User satisfaction: Acceptable / Issues: _____
- [ ] Cost savings target achieved: Yes/No

**Documentation:**
- [ ] Asset inventory updated (CMDB): Yes/No
- [ ] Network documentation updated: Yes/No
- [ ] Runbooks/SOPs updated: Yes/No
- [ ] Final project report completed: Yes/No
- [ ] Lessons learned documented: Yes/No

**Knowledge Transfer:**
- [ ] Team training completed: Yes/No
- [ ] Nutanix administration procedures documented: Yes/No
- [ ] Support handoff completed: Yes/No

**Project Closure:**
- [ ] All stakeholders notified of completion: Date: _____
- [ ] Final project review meeting held: Date: _____
- [ ] Project sponsor sign-off: Name: _____ Date: _____

---

*Document Version: 1.0*  
*Last Updated: May 2026*  
*Author: Lokesh Yadav*
