New-VHD -Path "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\Win10-Linked.vhdx" -ParentPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\Win10-Linked.vhdx" -Differencing

New-VM -Name "Win10-LinkedClone" -Generation 2 -MemoryStartupBytes 5GB -SwitchName "HyperV-WAN" -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\Win10-Linked.vhdx"

Start-VM -Name "Win10-LinkedClone"


