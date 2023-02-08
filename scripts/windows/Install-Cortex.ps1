wget "https://choco.lab.example.com/apps/cortex_x64.msi" -outfile "C:\payload\cortex_x64.msi"

msiexec.exe /i C:\payload\cortex_x64.msi /qn /norestart

Start-Sleep -s 15

Unregister-ScheduledTask -TaskName ClearActionCenter -Confirm:$false
Remove-Item C:\payload -Force -Recurse
