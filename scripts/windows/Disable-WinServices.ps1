Set-Service -Name MapsBroker -StartupType Disabled

# Set up remote access
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Enable-NetFirewallRule -DisplayGroup "Windows Management Instrumentation (WMI)"
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
Enable-PsRemoting
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value '0'
