# Migration Architecture Diagram

## Current State (Source): VMware ESXi Environment

```
┌─────────────────────────────────────────────────────────────────┐
│                     vCenter Server 7.0                          │
│                   (Management Layer)                            │
└────────────────────┬────────────────────────────────────────────┘
                     │
     ┌───────────────┼───────────────┬───────────────┐
     │               │               │               │
┌────▼─────┐   ┌────▼─────┐   ┌────▼─────┐   ┌────▼─────┐
│ ESXi-01  │   │ ESXi-02  │   │ ESXi-03  │   │ ESXi-04  │
│ Dell R740│   │ Dell R740│   │ Dell R740│   │ Dell R740│
│ 48 cores │   │ 48 cores │   │ 48 cores │   │ 48 cores │
│ 384 GB   │   │ 384 GB   │   │ 384 GB   │   │ 384 GB   │
└────┬─────┘   └────┬─────┘   └────┬─────┘   └────┬─────┘
     │              │              │              │
     │              │              │              │
     └──────────────┴──────────────┴──────────────┘
                    │
           ┌────────▼────────┐
           │  Dell EMC SAN   │
           │   Unity 380F    │
           │   50 TB usable  │
           │   iSCSI Storage │
           └─────────────────┘

Virtual Machines Distribution:
  - Active Directory/DNS: 4 VMs
  - SQL Servers: 12 VMs
  - File Servers: 8 VMs
  - Web/App Servers: 35 VMs
  - Development/Test: 25 VMs
  - Monitoring: 6 VMs
  - Others: 30 VMs
  Total: 120 VMs
```

## Target State: Nutanix AHV Environment

```
┌─────────────────────────────────────────────────────────────────┐
│                    Prism Central                                │
│              (Centralized Management)                           │
└────────────────────┬────────────────────────────────────────────┘
                     │
     ┌───────────────┼───────────────┬───────────────┐
     │               │               │               │
┌────▼─────┐   ┌────▼─────┐   ┌────▼─────┐   ┌────▼─────┐
│ AHV      │   │ AHV      │   │ AHV      │   │ AHV      │
│ Node-01  │   │ Node-02  │   │ Node-03  │   │ Node-04  │
│ + CVM    │   │ + CVM    │   │ + CVM    │   │ + CVM    │
│ 48 cores │   │ 48 cores │   │ 48 cores │   │ 48 cores │
│ 384 GB   │   │ 384 GB   │   │ 384 GB   │   │ 384 GB   │
│ 15TB SSD │   │ 15TB SSD │   │ 15TB SSD │   │ 15TB SSD │
└────┬─────┘   └────┬─────┘   └────┬─────┘   └────┬─────┘
     │              │              │              │
     └──────────────┴──────────────┴──────────────┘
                    │
          Nutanix Distributed 
          Storage Fabric (DSF)
          60TB usable capacity
          
Same 120 VMs migrated to AHV:
  - All workloads intact
  - IP addresses preserved
  - Network VLANs maintained
```

## Migration Flow

```
┌──────────────────┐
│   Source ESXi    │
│   Environment    │
└────────┬─────────┘
         │
         │ 1. Nutanix Move discovers VMs
         ▼
┌────────────────────────────────┐
│    Nutanix Move Appliance      │
│  - Connects to vCenter         │
│  - Connects to Nutanix         │
│  - Manages migration process   │
└────────┬───────────────────────┘
         │
         │ 2. Initial data seeding (VM stays on)
         │ 3. Final cutover (VM powers off)
         │ 4. Conversion & power on
         ▼
┌──────────────────┐
│  Target Nutanix  │
│  AHV Cluster     │
└──────────────────┘
```

## Network Architecture

```
Physical Network Infrastructure (Unchanged)
┌──────────────────────────────────────────────────┐
│  Core Network Switch                             │
└───┬──────┬──────┬──────┬──────┬──────┬──────────┘
    │      │      │      │      │      │
VLAN 10  20   30   40   50   60
 Mgmt  Prod  DMZ  Stor Bkup  Dev

Current (ESXi):
┌─────────────────────────────────────────┐
│ ESXi vSwitch0: VLAN 10 (Management)    │
│ ESXi vSwitch1: VLANs 20, 30 (Prod/DMZ)│
│ ESXi vSwitch2: VLAN 40 (Storage/iSCSI) │
│ ESXi vSwitch3: VLANs 50, 60 (Bkup/Dev)│
└─────────────────────────────────────────┘

Target (Nutanix):
┌─────────────────────────────────────────┐
│ AHV Networks:                           │
│  - Management (VLAN 10)                │
│  - Production (VLAN 20)                │
│  - DMZ (VLAN 30)                       │
│  - Backup (VLAN 50)                    │
│  - Development (VLAN 60)               │
│  (VLAN 40 not needed - internal DSF)   │
└─────────────────────────────────────────┘
```

## Migration Phases Timeline

```
Week 1-2: Assessment
├─ VM inventory
├─ Dependency mapping
└─ Migration planning

Week 3: Nutanix Deployment
├─ Cluster setup
├─ Prism config
└─ Network/VLAN setup

Week 4: Pilot Migration
├─ 5 test VMs
└─ Process validation

Week 5-6: Wave 1 (Low Priority)
├─ 30 Dev/Test VMs
└─ Minimal impact

Week 7-8: Wave 2 (Medium Priority)  <- Currently here
├─ 40 File/Web servers
└─ Scheduled downtime

Week 9-10: Wave 3 (Critical)
├─ 50 AD/SQL/Email VMs
└─ Careful execution

Week 11-12: Optimization
├─ Performance tuning
├─ ESXi decommission
└─ Documentation
```

## Data Flow During Migration

```
Step 1: Seeding (VM Running)
┌──────────┐                    ┌──────────┐
│  ESXi    │  Initial data     │ Nutanix  │
│  VM-01   │ ════════════════> │  VM-01   │
│ (Active) │  (background)     │ (Prep)   │
└──────────┘                    └──────────┘
     ↓
  Users still
  connected

Step 2: Cutover (Downtime Starts)
┌──────────┐                    ┌──────────┐
│  ESXi    │  Power off        │ Nutanix  │
│  VM-01   │ ────────────────> │  VM-01   │
│ (Off)    │  Final sync       │ (Sync)   │
└──────────┘                    └──────────┘
     ✗
  Downtime
  window

Step 3: Completion (Downtime Ends)
┌──────────┐                    ┌──────────┐
│  ESXi    │                    │ Nutanix  │
│  VM-01   │                    │  VM-01   │
│(PowerOff)│                    │ (Active) │
└──────────┘                    └──────────┘
                                     ↓
                                 Users
                                reconnect
```

## Storage Architecture Change

```
Before (ESXi + SAN):
┌─────────────────┐      ┌─────────────────┐
│  ESXi Hosts     │      │  Dell EMC SAN   │
│  (Compute)      │<────>│  (Storage)      │
│                 │ iSCSI│                 │
│  - 4 hosts      │      │  - Centralized  │
│  - Stateless    │      │  - Single point │
└─────────────────┘      └─────────────────┘

After (Nutanix HCI):
┌─────────────────────────────────────────┐
│  Nutanix Nodes (Hyperconverged)        │
│  ┌───────┐  ┌───────┐  ┌───────┐      │
│  │ AHV   │  │ AHV   │  │ AHV   │ ...  │
│  │ ───── │  │ ───── │  │ ───── │      │
│  │Storage│  │Storage│  │Storage│      │
│  └───┬───┘  └───┬───┘  └───┬───┘      │
│      └──────────┴──────────┘           │
│    Distributed Storage Fabric          │
└─────────────────────────────────────────┘
  - Compute + Storage in same nodes
  - No external SAN needed
  - Distributed, resilient
```

---

Notes:
- All diagrams are simplified for clarity
- Actual network topology may be more complex
- CVM = Controller VM (Nutanix storage controller)
- DSF = Distributed Storage Fabric
