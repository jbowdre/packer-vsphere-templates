Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }
