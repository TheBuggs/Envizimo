## Envizimo Software Pack

### Create custom Mozila Firefox installer

### Create all dpendency software into one click executable file

### Instalation

- Open Powershell like administrator
- Go to specific directorete where download necessary files
- Past command below into PowerShell prompt

```powershel
Invoke-WebRequest 'https://raw.githubusercontent.com/TheBuggs/Envizimo/main/download.ps1' -OutFile ./download.ps1; .\download.ps1
```

- Execute the command
- Navidate to folder eventis ( in folder exist .\one-click.ps1 file )
- Execute command below

```powershel
 .\one-click.ps1
```

- Now must be open prompt window and now you must be added info

  - add link for your homepage e.g. google.bg
  - add link for your dns record for from Envizimo

- after that wait to download and generete your custom installer...

You can find your installer into folder eventis with name 'pack.exe'. Install pack.exe like admin in machines. Right click over file adn choose "Run as admin".

### Optional
