
# Helper: Get Filtered VMs
function Get-FilteredVMs {
    param(
        [string]$NameContains
    )
    if ($NameContains) {
        return Get-VM | Where-Object { $_.Name -like "*$NameContains*" }
    } else {
        return Get-VM
    }
}

# Restore the Latest Snapshot
function Restore-LatestSnapshot {
    param([VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl]$VM)

    $snap = Get-Snapshot -VM $VM | Sort-Object -Property Created -Descending | Select-Object -First 1
    if (-not $snap) {
        Write-Host "No snapshots found for $($VM.Name)"
        return
    }

    Write-Host "Restoring latest snapshot for $($VM.Name): $($snap.Name)"
    Restore-Snapshot -Snapshot $snap -Confirm:$false
}

# Create a Full Clone of a VM
function Clone-FullVM {
    param(
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl]$VM,
        [string]$CloneName,
        [string]$Folder = $null,
        [string]$ResourcePool = $null,
        [string]$Datastore = $null
    )

    Write-Host "Cloning $($VM.Name) → $CloneName"

    $folderObj = if ($Folder)       { Get-Folder -Name $Folder }       else { $VM.Folder }
    $rpObj     = if ($ResourcePool) { Get-ResourcePool -Name $ResourcePool } else { $VM.ResourcePool }
    $dsObj     = if ($Datastore)    { Get-Datastore -Name $Datastore } else { $VM.DatastoreIdList | Get-Datastore }

    New-VM -Name $CloneName `
           -VM $VM `
           -VMHost $VM.VMHost `
           -ResourcePool $rpObj `
           -Datastore $dsObj `
           -Location $folderObj | Out-Null
}

# Modify CPU / Memory
function Update-VMPerformance {
    param(
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl]$VM,
        [int]$CPU,
        [int]$MemoryGB
    )

    Write-Host "Updating performance for $($VM.Name)"

    if ($CPU) {
        Set-VM -VM $VM -NumCPU $CPU -Confirm:$false
    }
    if ($MemoryGB) {
        Set-VM -VM $VM -MemoryGB $MemoryGB -Confirm:$false
    }
}


# Delete VM from Disk
function Delete-VMFromDisk {
    param([VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl]$VM)

    Write-Host "Deleting VM from disk: $($VM.Name)"
    Remove-VM -VM $VM -DeletePermanently -Confirm:$false
}

# Copy a File to a VM
function Copy-FileToVM {
    param(
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl]$VM,
        [string]$SourcePath,
        [string]$DestinationPath,
        [string]$Username,
        [string]$Password
    )

    Write-Host "Copying $SourcePath → $($VM.Name):$DestinationPath"

    $cred = New-Object PSCredential ($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))

    Copy-VMGuestFile `
        -VM $VM `
        -LocalToGuest `
        -Source $SourcePath `
        -Destination $DestinationPath `
        -GuestUser $Username `
        -GuestPassword $Password `
        -Force
}

# Execute a Command inside Guest
function Invoke-VMCommand {
    param(
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl]$VM,
        [string]$Command,
        [string[]]$Arguments,
        [string]$Username,
        [string]$Password
    )

    Write-Host "Executing command on $($VM.Name): $Command $Arguments"

    Invoke-VMScript `
        -VM $VM `
        -ScriptText "$Command $($Arguments -join ' ')" `
        -GuestUser $Username `
        -GuestPassword $Password
}

# Function to apply one action to multiple VMs
function Invoke-ActionOnFilteredVMs {
    param(
        [string]$NameFilter,
        [scriptblock]$Action,
        $Arguments
    )

    $vms = Get-FilteredVMs -NameContains $NameFilter

    foreach ($vm in $vms) {
        Write-Host "---- Executing on VM: $($vm.Name) ----" -ForegroundColor Cyan
        & $Action $vm @Arguments
    }
}
