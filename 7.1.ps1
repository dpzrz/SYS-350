$vmName = Read-Host "Enter the name of the VM to manage"

Write-Host "Stopping VM '$vmName'"
Stop-VM -Name $vmName -Force
Start-Sleep -Seconds 2
Get-VM -Name $vmName | Select-Object Name, State

Write-Host "Creating Checkpoint" 
$snapshotName = Read-Host "Enter a name for the checkpoint"
Checkpoint-VM -Name $vmName -SnapshotName $snapshotName
Write-Host "Checkpoint '$snapshotName' created successfully" 
Get-VMSnapshot -VMName $vmName | Select-Object VMName, Name, CreationTime


Write-Host "`Starting VM '$vmName'" 
Start-VM -Name $vmName
Start-Sleep -Seconds 2
Get-VM -Name $vmName | Select-Object Name, State


Write-Host "Switching VM Network"
Write-Host "Available virtual switches:" 
Get-VMSwitch | Select-Object Name, SwitchType

$switchName = Read-Host "Enter the name of the switch to connect '$vmName' to"
Connect-VMNetworkAdapter -VMName $vmName -SwitchName $switchName

Write-Host "VM network switched successfully"
Get-VMNetworkAdapter -VMName $vmName | Select-Object VMName, SwitchName
