wget "https://choco.lab.example.com/apps/vmtools_x64.exe" -outfile "C:\payload\vmtools_x64.exe"

Start-Process "C:\payload\vmtools_x64.exe" -ArgumentList '/s /v "/qb REBOOT=R"' -Wait
