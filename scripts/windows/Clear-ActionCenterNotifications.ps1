Start ms-actioncenter:
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("+{TAB}")
[System.Windows.Forms.SendKeys]::SendWait("+{TAB}")
[System.Windows.Forms.SendKeys]::SendWait(" ")
Start-Sleep -Milliseconds 1000
[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
