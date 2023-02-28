Invoke-WebRequest 'https://github.com/TheBuggs/Envizimo/archive/refs/heads/main.zip' -OutFile .\eventis.zip -UseBasicParsing
Start-Sleep 2
Expand-Archive .\eventis.zip .\
Start-Sleep 2
Remove-Item .\eventis.zip -Force -Verbose
Start-Sleep 2
Rename-Item .\Envizimo-main .\eventis
Start-Sleep 1
Set-Location .\eventis