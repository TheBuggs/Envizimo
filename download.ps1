Invoke-WebRequest 'https://github.com/TheBuggs/Envizimo.git' -OutFile .\eventis.zip
Expand-Archive .\eventis.zip .\
Remove-Item .\eventis.zip