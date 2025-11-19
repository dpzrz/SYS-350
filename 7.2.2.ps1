function Select-VMs {
    $vms = Get-VM
    if ($vms.Count -eq 0) { return $null }

    Write-Host "Select VM(s):"
    $i = 1
    $map = @{}
    foreach ($vm in $vms) {
        Write-Host "[$i] $($vm.Name)"
        $map[$i] = $vm
        $i++
    }

    $choice = Read-Host "`nEnter numbers (comma separated) or 'all'"
    if ($choice -eq "all") { return $vms }

    $indexes = $choice -split "," | ForEach-Object { $_.Trim() }
    return $indexes | ForEach-Object { $map[[int]$_] }
}

function Restore-LatestSnapshot {
    param($VM)

    $snap = Get-VMSnapshot -VMName $VM.Name |
            Sort-Object CreationTime -Descending |
            Select-Object -First 1

    if (-not $snap) { return }

    Restore-VMSnapshot -VMName $VM.Name -Name $snap.Name -Confirm:$false
}

function Clone-FullVM {
    param($VM)

    $CloneName = Read-Host "New clone name"
    $CloneDir = Read-Host "Folder for clone"

    $disk = (Get-VMHardDiskDrive -VMName $VM.Name).Path

    $cloneFolder = Join-Path $CloneDir $CloneName
    $cloneDisk = Join-Path $cloneFolder "$CloneName.vhdx"

    New-Item -ItemType Directory -Path $cloneFolder -Force | Out-Null
    Copy-Item $disk $cloneDisk -Force

    New-VM -Name $CloneName `
           -Generation $VM.Generation `
           -MemoryStartupBytes $VM.MemoryStartup `
           -VHDPath $cloneDisk `
           -SwitchName (Get-VMNetworkAdapter -VMName $VM.Name).SwitchName
}

function Update-VMPerformance {
    param($VM)

    $cpu = Read-Host "New CPU count (empty to skip)"
    $mem = Read-Host "New RAM in MB (empty to skip)"

    if ($cpu) {
        Set-VMProcessor -VMName $VM.Name -Count $cpu
    }

    if ($mem) {
        Set-VMMemory -VMName $VM.Name -DynamicMemoryEnabled $false `
                     -StartupBytes ($mem * 1MB)
    }
}

function Delete-VMFromDisk {
    param($VM)

    $confirm = Read-Host "Delete $($VM.Name) permanently? (yes/no)"
    if ($confirm -ne "yes") { return }

    Stop-VM $VM.Name -Force -ErrorAction SilentlyContinue
    $disk = (Get-VMHardDiskDrive -VMName $VM.Name).Path
    $config = $VM.Path

    Remove-VM $VM.Name -Force

    if (Test-Path $disk) { Remove-Item $disk -Force }
    if (Test-Path $config) { Remove-Item $config -Recurse -Force }
}

function Copy-FileToVM {
    param($VM)

    $src = Read-Host "Path to source file"
    $dst = Read-Host "Destination path inside VM"

    Copy-VMFile -Name $VM.Name `
                -SourcePath $src `
                -DestinationPath $dst `
                -FileSource Host -CreateFullPath
}

function Invoke-VMCommand {
    param($VM)

    $cmd = Read-Host "Enter command"

    Invoke-Command -VMName $VM.Name -ScriptBlock { param($cmd) Invoke-Expression $cmd } `
                   -ArgumentList $cmd
}

function Show-Menu {
    Clear-Host
    Write-Host "========================================="
    Write-Host "      Hyper-V Virtual Machine Manager"
    Write-Host "=========================================`n"
    Write-Host "[1] Restore Latest Snapshot"
    Write-Host "[2] Clone VM"
    Write-Host "[3] Change CPU / Memory"
    Write-Host "[4] Delete VM"
    Write-Host "[5] Copy File to VM"
    Write-Host "[6] Run Command on VM"
    Write-Host "[7] Exit`n"

    return Read-Host "Choose an option"
}

while ($true) {
    $choice = Show-Menu
    if ($choice -eq "7") { break }

    $selectedVMs = Select-VMs
    if (-not $selectedVMs) { continue }

    foreach ($vm in $selectedVMs) {
        switch ($choice) {
            "1" { Restore-LatestSnapshot -VM $vm }
            "2" { Clone-FullVM -VM $vm }
            "3" { Update-VMPerformance -VM $vm }
            "4" { Delete-VMFromDisk -VM $vm }
            "5" { Copy-FileToVM -VM $vm }
            "6" { Invoke-VMCommand -VM $vm }
        }
    }

    Write-Host "`nDone. Press Enter to continue..."
    Read-Host
}
