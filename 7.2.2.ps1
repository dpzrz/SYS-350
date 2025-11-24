```powershell
# Hyper-V VM Management Script

function Restore-LatestSnapshot {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$VMNames
    )
    
    foreach ($VMName in $VMNames) {
        $vm = Get-VM -Name $VMName
        if ($vm.State -ne 'Off') {
            Stop-VM -Name $VMName -Force
        }
        
        $latestSnapshot = Get-VMSnapshot -VMName $VMName | Sort-Object CreationTime -Descending | Select-Object -First 1
        if ($latestSnapshot) {
            Restore-VMSnapshot -VMSnapshot $latestSnapshot -Confirm:$false
            Write-Host "Restored latest snapshot for $VMName"
        } else {
            Write-Host "No snapshots found for $VMName"
        }
    }
}

function New-VMFullClone {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourceVMName,
        [Parameter(Mandatory=$true)]
        [string]$CloneName,
        [Parameter(Mandatory=$true)]
        [string]$DestinationPath
    )
    
    $vm = Get-VM -Name $SourceVMName
    if ($vm.State -ne 'Off') {
        Stop-VM -Name $SourceVMName -Force
    }
    
    $sourceVM = Get-VM -Name $SourceVMName
    $sourceVHDs = Get-VMHardDiskDrive -VMName $SourceVMName
    
    Export-VM -Name $SourceVMName -Path $DestinationPath
    
    $exportedPath = Join-Path $DestinationPath $SourceVMName
    $clonePath = Join-Path $DestinationPath $CloneName
    
    Rename-Item -Path $exportedPath -NewName $CloneName
    
    $vmConfigPath = Get-ChildItem -Path $clonePath -Recurse -Filter "*.vmcx" | Select-Object -First 1
    Import-VM -Path $vmConfigPath.FullName -Copy -GenerateNewId
    
    Rename-VM -Name $SourceVMName -NewName $CloneName
    
    Write-Host "Created full clone: $CloneName"
}

function Set-VMPerformance {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$VMNames,
        [int]$MemoryGB,
        [int]$ProcessorCount
    )
    
    foreach ($VMName in $VMNames) {
        $vm = Get-VM -Name $VMName
        if ($vm.State -ne 'Off') {
            Stop-VM -Name $VMName -Force
        }
        
        if ($MemoryGB) {
            Set-VMMemory -VMName $VMName -StartupBytes ($MemoryGB * 1GB)
            Write-Host "Set memory to $MemoryGB GB for $VMName"
        }
        
        if ($ProcessorCount) {
            Set-VMProcessor -VMName $VMName -Count $ProcessorCount
            Write-Host "Set processor count to $ProcessorCount for $VMName"
        }
    }
}

function Remove-VMFromDisk {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$VMNames
    )
    
    foreach ($VMName in $VMNames) {
        $vm = Get-VM -Name $VMName
        if ($vm.State -ne 'Off') {
            Stop-VM -Name $VMName -Force
        }
        
        $vhdPaths = (Get-VMHardDiskDrive -VMName $VMName).Path
        $vmPath = $vm.Path
        
        Remove-VM -Name $VMName -Force
        
        foreach ($vhdPath in $vhdPaths) {
            if (Test-Path $vhdPath) {
                Remove-Item -Path $vhdPath -Force
                Write-Host "Deleted VHD: $vhdPath"
            }
        }
        
        Write-Host "Deleted VM: $VMName"
    }
}

function Copy-FileToVM {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,
        [Parameter(Mandatory=$true)]
        [string]$DestinationPath
    )
    
    $vm = Get-VM -Name $VMName
    if ($vm.State -ne 'Off') {
        Stop-VM -Name $VMName -Force
    }
    
    Copy-VMFile -VMName $VMName -SourcePath $SourcePath -DestinationPath $DestinationPath -FileSource Host -CreateFullPath
    Write-Host "Copied $SourcePath to $VMName at $DestinationPath"
}

function Invoke-CommandOnVM {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [string]$Command,
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential
    )
    
    $vm = Get-VM -Name $VMName
    if ($vm.State -ne 'Off') {
        Stop-VM -Name $VMName -Force
    }
    
    $session = New-PSSession -VMName $VMName -Credential $Credential
    $result = Invoke-Command -Session $session -ScriptBlock {
        param($cmd)
        Invoke-Expression $cmd
    } -ArgumentList $Command
    Remove-PSSession -Session $session
    
    Write-Host "Executed command on $VMName"
    return $result
}

function Start-VMPowerOn {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$VMNames
    )
    
    foreach ($VMName in $VMNames) {
        $vm = Get-VM -Name $VMName
        if ($vm.State -ne 'Off') {
            Stop-VM -Name $VMName -Force
        }
        
        Start-VM -Name $VMName
        Write-Host "Powered on $VMName"
    }
}

function Stop-VMPowerOff {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$VMNames
    )
    
    foreach ($VMName in $VMNames) {
        $vm = Get-VM -Name $VMName
        if ($vm.State -ne 'Off') {
            Stop-VM -Name $VMName -Force
        }
        
        Write-Host "Powered off $VMName"
    }
}
```
