function Get-VMSummary {
    $vms = Get-VM

    Write-Host "Getting VMs..." 

    foreach ($vm in $vms) {
        $ip = (Get-VMNetworkAdapter -VMName $vm.Name).IPAddresses

        Write-Host "`nVM Name: $($vm.Name)" 
        Write-Host "Power State: $($vm.State)"
        Write-Host "IP Address: $ip"
    }
}


function Get-VMDetailedInfo {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName
    )

    Write-Host "Getting $VMName info" 

    try {
        $vm = Get-VM -Name $VMName -ErrorAction Stop
        $cpu = Get-VMProcessor -VMName $VMName
        $disk = Get-VMHardDiskDrive -VMName $VMName
        $net = Get-VMNetworkAdapter -VMName $VMName

        Write-Host "`nVM Name: $($vm.Name)" -ForegroundColor Yellow
        Write-Host "Power State: $($vm.State)"
        Write-Host "CPU Count: $($cpu.Count)"
        Write-Host "Memory (in GB): $([math]::Round($vm.MemoryAssigned / 1GB, 2))"
        Write-Host "Disk: $($disk.Path)"
        Write-Host "Network Switch: $($net.SwitchName)"
    }
    catch {
        Write-Host "Error: VM '$VMName' not found" 
    }
}

function New-VMSnapshotCustom {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [string]$SnapshotName
    )

    $vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if ($vm -eq $null) {
        Write-Host "VM '$VMName' not found." 
        return
    }

    try {
        Checkpoint-VM -Name $VMName -SnapshotName $SnapshotName
        Write-Host "Snapshot '$SnapshotName' created successfully for VM '$VMName'." 
    }
    catch {
        Write-Host "Error creating snapshot: $_" 
    }
}


function Restore-VMSnapshotCustom {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [string]$SnapshotName
    )

    $vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if ($vm -eq $null) {
        Write-Host "VM '$VMName' not found." 
        return
    }

    try {
        Restore-VMSnapshot -VMName $VMName -Name $SnapshotName -Confirm:$false
        Write-Host "VM '$VMName' restored to snapshot '$SnapshotName' successfully."
    }
    catch {
        Write-Host "Error restoring snapshot: $_" 
    }
}


function Remove-VMSnapshotCustom {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [string]$SnapshotName
    )

    $vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if ($vm -eq $null) {
        Write-Host "VM '$VMName' not found." 
        return
    }

    try {
        Remove-VMSnapshot -VMName $VMName -Name $SnapshotName -Confirm:$false
        Write-Host "Snapshot '$SnapshotName' deleted successfully from VM '$VMName'."
    }
    catch {
        Write-Host "Error deleting snapshot: $_" 
    }
}


function Set-VMPowerState {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Start", "Stop")]
        [string]$Action
    )

    $vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if ($vm -eq $null) {
        Write-Host "VM '$VMName' not found." 
        return
    }

    try {
        if ($Action -eq "Start") {
            Start-VM -Name $VMName
            Write-Host "VM '$VMName' started successfully." 
        }
        else {
            Stop-VM -Name $VMName -Force
            Write-Host "VM '$VMName' stopped successfully." 
        }
    }
    catch {
        Write-Host "Error changing power state: $_" 
    }
}


function Copy-VMFull {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourceVMName,
        [Parameter(Mandatory=$true)]
        [string]$CloneName,
        [Parameter(Mandatory=$false)]
        [string]$VHDPath = "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\"
    )

    $vm = Get-VM -Name $SourceVMName -ErrorAction SilentlyContinue

    if ($vm -eq $null) {
        Write-Host "VM '$SourceVMName' not found." 
        return
    }

    try {
        Write-Host "Cloning VM '$SourceVMName' to '$CloneName'..."

        $sourceDisk = Get-VMHardDiskDrive -VMName $SourceVMName
        $newDiskPath = Join-Path $VHDPath "$CloneName.vhdx"

        # Copy the VHD
        Write-Host "Copying virtual hard disk..." -ForegroundColor Yellow
        Copy-Item -Path $sourceDisk.Path -Destination $newDiskPath

        # Create new VM
        Write-Host "Creating VM..." -ForegroundColor Yellow
        New-VM -Name $CloneName -MemoryStartupBytes $vm.MemoryStartup -Generation $vm.Generation -NoVHD

        # Attach the copied disk
        Add-VMHardDiskDrive -VMName $CloneName -Path $newDiskPath

        # Copy CPU configuration
        $cpuCount = (Get-VMProcessor -VMName $SourceVMName).Count
        Set-VMProcessor -VMName $CloneName -Count $cpuCount

        # Copy network configuration
        $sourceNet = Get-VMNetworkAdapter -VMName $SourceVMName
        Connect-VMNetworkAdapter -VMName $CloneName -SwitchName $sourceNet.SwitchName

        Write-Host "VM '$CloneName' created successfully as a clone of '$SourceVMName'."
    }
    catch {
        Write-Host "Error cloning VM: $_"
    }
}

function Remove-VMCustom {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [switch]$Force
    )

    $vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if ($vm -eq $null) {
        Write-Host "VM '$VMName' not found."
        return
    }

    if (-not $Force) {
        $confirmation = Read-Host "Are you sure you want to delete VM '$VMName'? (Y/N)"
        if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
            Write-Host "VM deletion cancelled." 
            return
        }
    }

    try {
        Remove-VM -Name $VMName -Force
        Write-Host "VM '$VMName' deleted successfully."
    }
    catch {
        Write-Host "Error deleting VM: $_" 
    }
}
