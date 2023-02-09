$scriptContent = @"
Start ms-actioncenter:
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("+{TAB}")
[System.Windows.Forms.SendKeys]::SendWait("+{TAB}")
[System.Windows.Forms.SendKeys]::SendWait(" ")
[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
Start ms-actioncenter:
Start-Sleep -s 4
[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
"@

Set-Content -Path C:\payload\Clear-ActionCenterNotifications.ps1 -Value $scriptContent

[string]$taskName = 'ClearActionCenter'
[string]$updateScriptPath = 'c:\payload\Clear-ActionCenterNotifications.ps1'

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-file $updateScriptPath -ExecutionPolicy Bypass -WindowStyle Minimized"
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -User 'LocalAdm' -TaskName $taskName -Trigger $trigger -Description "created by Packer"
#Start-ScheduledTask -TaskName $taskName
#Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
