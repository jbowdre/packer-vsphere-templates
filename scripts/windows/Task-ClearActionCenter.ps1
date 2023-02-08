wget "https://choco.lab.example.com/apps/Clear-ActionCenterNotifications.ps1.txt" -outfile "C:\payload\Clear-ActionCenterNotifications.ps1"
[string]$taskName = 'ClearActionCenter'
[string]$updateScriptPath = 'c:\payload\Clear-ActionCenterNotifications.ps1'

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-file $updateScriptPath -ExecutionPolicy Bypass -WindowStyle Minimized"
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -User 'LocalAdm' -TaskName $taskName -Trigger $trigger -Description "created by Packer"
#Start-ScheduledTask -TaskName $taskName
#Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
