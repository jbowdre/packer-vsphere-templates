wget "https://choco.lab.example.com/apps/safenet_x64.msi" -outfile "C:\payload\safenet_x64.msi"

msiexec.exe /i C:\payload\safenet_x64.msi ALLUSERS=1 /qn /norestart
