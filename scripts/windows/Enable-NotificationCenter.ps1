Remove-Item "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force
New-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -PropertyType DWORD -Value 1 -Force
Stop-Process -Name explorer -Force
