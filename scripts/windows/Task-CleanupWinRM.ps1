wget "https://choco.lab.example.com/apps/Clean-WinRMConfig.ps1.txt" -OutFile "C:\Clean-WinRMConfig.ps1"
$action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument "C:\Clean-WinRMConfig.ps1"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -User 'SYSTEM' -TaskName CleanupWinRM -Trigger $trigger -Description "created by Packer"
