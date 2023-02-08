wget "https://choco.lab.example.com/apps/qualys4.9_wks.msi" -outfile "C:\payload\qualys4.9_wks.msi"

New-NetFirewallRule -DisplayName "Block Qualys Agent" -Direction Outbound -InterfaceType Any -Action Block -Program "C:\Program Files\Qualys\QualysAgent\QualysAgent.exe"

msiexec.exe /i C:\payload\qualys4.9_wks.msi /qn /norestart
