wget "https://choco.lab.example.com/apps/laps_x64.msi" -outfile "C:\payload\laps_x64.msi"

msiexec.exe /i C:\payload\laps_x64.msi ALLUSERS=1 /qn /norestart
