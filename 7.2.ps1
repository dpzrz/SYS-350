function Get-VmSummary {
    [CmdletBinding()]
    param()
    $vms = Get-VM

    $vms | ForEach-Object {
        $ip = (Get-VMNetworkAdapter -VMName $_.Name).IPAddresses |
              Where-Object { $_ -notmatch ":" } 

        [PSCustomObject]@{
            Name       = $_.Name
            PowerState = $_.State
            IPAddress  = if ($ip) { $ip -join ", " } else { "N/A" }
        }
    }
}

function Get-VmDetail {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$VMName
    )

    $vm = Get-VM -Name $VMName -ErrorAction Stop
    $net = Get-VMNetworkAdapter -VMName $VMName

    [PSCustomObject]@{
        Name            = $vm.Name
        PowerState      = $vm.State
        CPUCount        = $vm.ProcessorCount
        MemoryAssigned  = $vm.MemoryAssigned
        MACAddress      = $net.MacAddress
    }
}
