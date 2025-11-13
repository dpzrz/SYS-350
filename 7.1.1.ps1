
$ParentVHD = "D:\VMs\BaseImages\Win10-Base.vhdx"

$ChildVHD = "D:\VMs\LinkedClones\Win10-Linked.vhdx"

$VMName = "Win10-LinkedClone"

$VMSwitch = "Default Switch"


Write-Host "Creating differencing disk (linked clone)..." -ForegroundColor Cyan
New-VHD -Path $ChildVHD -ParentPath $ParentVHD -Differencing -SizeBytes 60GB

Write-Host "Creating new VM using linked clone..." -ForegroundColor Cyan
New-VM -Name $VMName -MemoryStartupBytes 4GB -Generation 2 -VHDPath $ChildVHD -SwitchName $VMSwitch

Set-VMProcessor -VMName $VMName -Count 4
Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false

Write-Host "Starting VM..." -ForegroundColor Cyan
Start-VM -Name $VMName

Write-Host "`nLinked clone successfully created!" -ForegroundColor Green

