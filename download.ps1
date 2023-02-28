Invoke-WebRequest 'https://github.com/TheBuggs/Envizimo.zip' -OutFile .\eventis.zip
Expand-Archive .\eventis.zip .\
Remove-Item .\eventis.zip