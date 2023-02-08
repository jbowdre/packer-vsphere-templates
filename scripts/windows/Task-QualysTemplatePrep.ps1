wget "https://choco.lab.example.com/apps/Clear-QualysFWRule.ps1.txt" -OutFile "C:\Clear-QualysFWRule.ps1"
$action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument "C:\Clear-QualysFWRule.ps1"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -User 'SYSTEM' -TaskName QualysTemplatePrep -Trigger $trigger -Description "created by Packer"
