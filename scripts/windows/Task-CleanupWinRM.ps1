$scriptContent = @"
Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -Like 'CN=WS20*' } | Remove-Item
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
Unregister-ScheduledTask -TaskNAme CleanupWinRM -Confirm:$false
Remove-Item C:\Clean-WinRMConfig.ps1 -Force
"@

Set-Content -Path C:\Clean-WinRMConfig.ps1 -Value $scriptContent

$action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument "C:\Clean-WinRMConfig.ps1"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -User 'SYSTEM' -TaskName CleanupWinRM -Trigger $trigger -Description "created by Packer"
