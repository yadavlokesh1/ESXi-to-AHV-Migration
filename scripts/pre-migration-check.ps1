# Pre-Migration VM Check Script
# Author: Lokesh Yadav
# Last updated: May 2026
# Quick script to validate VM before migration - run this from PowerCLI

param(
    [Parameter(Mandatory=$true)]
    [string]$VMName,
    
    [Parameter(Mandatory=$false)]
    [string]$vCenter = "vcenter.company.local"
)

# Connect to vCenter (comment out if already connected)
# Connect-VIServer -Server $vCenter

Write-Host "`n=== Pre-Migration Check for $VMName ===" -ForegroundColor Cyan

try {
    $vm = Get-VM -Name $VMName -ErrorAction Stop
    
    # Basic VM info
    Write-Host "`n[VM Configuration]" -ForegroundColor Yellow
    Write-Host "Name: $($vm.Name)"
    Write-Host "Power State: $($vm.PowerState)"
    Write-Host "vCPU: $($vm.NumCpu)"
    Write-Host "Memory: $($vm.MemoryGB) GB"
    Write-Host "Provisioned Space: $([math]::Round($vm.ProvisionedSpaceGB,2)) GB"
    Write-Host "Used Space: $([math]::Round($vm.UsedSpaceGB,2)) GB"
    
    # VMware Tools check
    Write-Host "`n[VMware Tools]" -ForegroundColor Yellow
    $vmView = $vm | Get-View
    $toolsStatus = $vmView.Guest.ToolsStatus
    $toolsVersion = $vmView.Guest.ToolsVersion
    
    Write-Host "Status: $toolsStatus"
    Write-Host "Version: $toolsVersion"
    
    if ($toolsStatus -ne "toolsOk") {
        Write-Host "WARNING: VMware Tools not running properly!" -ForegroundColor Red
    }
    
    # Snapshot check
    Write-Host "`n[Snapshots]" -ForegroundColor Yellow
    $snapshots = $vm | Get-Snapshot
    
    if ($snapshots) {
        Write-Host "Found $($snapshots.Count) snapshot(s):" -ForegroundColor Red
        $snapshots | ForEach-Object {
            Write-Host "  - $($_.Name) (Created: $($_.Created), Size: $([math]::Round($_.SizeGB,2)) GB)"
        }
        Write-Host "Consider removing snapshots before migration" -ForegroundColor Yellow
    } else {
        Write-Host "No snapshots - Good!" -ForegroundColor Green
    }
    
    # Network info
    Write-Host "`n[Network Configuration]" -ForegroundColor Yellow
    $vm.NetworkAdapters | ForEach-Object {
        Write-Host "Adapter: $($_.Name)"
        Write-Host "  Network: $($_.NetworkName)"
        Write-Host "  Type: $($_.Type)"
        Write-Host "  MAC: $($_.MacAddress)"
    }
    
    # Disk info
    Write-Host "`n[Virtual Disks]" -ForegroundColor Yellow
    $vm.HardDisks | ForEach-Object {
        Write-Host "Disk: $($_.Name)"
        Write-Host "  Capacity: $([math]::Round($_.CapacityGB,2)) GB"
        Write-Host "  Storage Format: $($_.StorageFormat)"
    }
    
    # Guest OS info
    Write-Host "`n[Guest OS]" -ForegroundColor Yellow
    Write-Host "OS: $($vmView.Config.GuestFullName)"
    Write-Host "Hostname: $($vmView.Guest.HostName)"
    Write-Host "IP Address: $($vmView.Guest.IpAddress)"
    
    # Summary
    Write-Host "`n=== Pre-Migration Checklist ===" -ForegroundColor Cyan
    Write-Host "[$(if($vm.PowerState -eq 'PoweredOn'){'✓'}else{'✗'})] VM is powered on"
    Write-Host "[$(if($toolsStatus -eq 'toolsOk'){'✓'}else{'✗'})] VMware Tools running"
    Write-Host "[$(if(!$snapshots){'✓'}else{'✗'})] No snapshots present"
    
    Write-Host "`nVM ready for migration assessment" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR: Could not find VM '$VMName'" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Disconnect (uncomment if you want to auto-disconnect)
# Disconnect-VIServer -Server $vCenter -Confirm:$false
