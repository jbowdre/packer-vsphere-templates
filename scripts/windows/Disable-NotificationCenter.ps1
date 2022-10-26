New-Item "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | New-ItemProperty -Name "DisableNotificationCenter" -PropertyType DWORD -Value 1 -Force | Out-Null
New-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -PropertyType DWORD -Value 0 -Force
Stop-Process -Name explorer -Force
