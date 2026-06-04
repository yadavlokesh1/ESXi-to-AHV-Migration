# Post-Migration Validation Script
# Quick checks after VM migrated to Nutanix AHV
# Run this from the migrated VM itself

$vmName = $env:COMPUTERNAME
$logFile = "C:\Temp\post-migration-validation.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append
    Write-Host $Message
}

Write-Log "=== Post-Migration Validation for $vmName ==="

# Check OS
Write-Log "`n[Operating System]"
$os = Get-CimInstance Win32_OperatingSystem
Write-Log "OS: $($os.Caption)"
Write-Log "Version: $($os.Version)"
Write-Log "Last Boot: $($os.LastBootUpTime)"

# Check network
Write-Log "`n[Network Connectivity]"
$adapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
Write-Log "Active adapters: $($adapters.Count)"

foreach ($adapter in $adapters) {
    Write-Log "  Adapter: $($adapter.Name)"
    $ip = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
    if ($ip) {
        Write-Log "    IP: $($ip.IPAddress)"
    }
}

# Test connectivity
Write-Log "`n[Connectivity Tests]"
$targets = @{
    "Gateway" = (Get-NetRoute -DestinationPrefix "0.0.0.0/0").NextHop | Select-Object -First 1
    "DNS" = (Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object {$_.ServerAddresses}).ServerAddresses[0]
    "Domain Controller" = "dc01.company.local"  # update with your DC
}

foreach ($target in $targets.GetEnumerator()) {
    $result = Test-Connection -ComputerName $target.Value -Count 2 -Quiet
    $status = if ($result) { "OK" } else { "FAILED" }
    Write-Log "$($target.Key): $status ($($target.Value))"
}

# Check services
Write-Log "`n[Windows Services]"
$autoServices = Get-Service | Where-Object {$_.StartType -eq "Automatic" -and $_.Status -ne "Running"}
if ($autoServices) {
    Write-Log "WARNING: $($autoServices.Count) automatic services not running:"
    $autoServices | ForEach-Object { Write-Log "  - $($_.Name): $($_.Status)" }
} else {
    Write-Log "All automatic services running - Good!"
}

# Check disks
Write-Log "`n[Disk Status]"
Get-Volume | Where-Object {$_.DriveLetter} | ForEach-Object {
    $freePercent = [math]::Round(($_.SizeRemaining / $_.Size) * 100, 1)
    Write-Log "$($_.DriveLetter): $($_.FileSystemLabel) - $freePercent% free - Health: $($_.HealthStatus)"
}

# Check event logs (errors in last hour)
Write-Log "`n[Recent Event Log Errors]"
$errors = Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddHours(-1) -ErrorAction SilentlyContinue
if ($errors) {
    Write-Log "Found $($errors.Count) system errors in last hour"
    $errors | Select-Object -First 5 | ForEach-Object {
        Write-Log "  [$($_.TimeGenerated)] $($_.Source): $($_.Message.Substring(0, [Math]::Min(100, $_.Message.Length)))"
    }
} else {
    Write-Log "No system errors in last hour - Good!"
}

# Domain check (if domain joined)
Write-Log "`n[Domain Connectivity]"
$domain = (Get-WmiObject Win32_ComputerSystem).Domain
if ($domain -ne "WORKGROUP") {
    Write-Log "Domain: $domain"
    
    try {
        $dcTest = nltest /sc_query:$domain 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Secure channel to domain: OK"
        } else {
            Write-Log "WARNING: Secure channel test failed"
        }
    } catch {
        Write-Log "Could not test domain connectivity"
    }
}

Write-Log "`n=== Validation Complete ==="
Write-Log "Log saved to: $logFile"
