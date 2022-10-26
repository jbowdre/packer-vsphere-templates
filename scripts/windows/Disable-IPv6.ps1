Get-NetAdapter | foreach { Disable-NetAdapterBinding -Name $_.Name -ComponentID ms_tcpip6 }
