---
title: "My Report"
output:
  html_document:
    number_sections: true
---

# Envizimo Software Pack

## Create custom Mozila Firefox installer

## Create all dpendency software into one executable file

## Installation

### Open Powershell like administrator

### Go to specific directorete where download all necessary files e.g your desktop C:\Users\%username%\Desktop

```powershel
Set-Location $Env:USERPROFILE\Desktop
```

### Pаstе command below into PowerShell prompt

```powershel
Invoke-WebRequest 'https://raw.githubusercontent.com/TheBuggs/Envizimo/main/download.ps1' -OutFile ./download.ps1; .\download.ps1
```

### Execute the command

### Now you write information for your homepage and bookmark link (Please add https:// before address)

#### Add link for your homepage e.g. https://google.bg

#### Add link for your envizimo site e.g. https://my.site.tld

### after that wait to download and generete your custom installer...

You can find your installer into folder "./eventis" with name 'pack.exe'. Install pack.exe like admin into machine - click right mouse button over file and choose "Run as admin" and start process to install all necessery software to your computer.

## Demo
