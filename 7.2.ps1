function Get-VmSummary {
    [CmdletBinding()]
    param()

    # Get all VMs
    $vms = Get-VM

    $vms | ForEach-Object {
        # Try to get IPs (works for VMs with integration services)
        $ip = (Get-VMNetworkAdapter -VMName $_.Name).IPAddresses |
              Where-Object { $_ -notmatch ":" } # filter IPv6 if desired

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
