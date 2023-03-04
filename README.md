# Envizimo Software Pack

## 1. Create custom Mozila Firefox installer

## 2. Create all dpendency software into one executable file

## 3. Installation

### 3.1. Open Powershell like administrator

### 3.2. Go to specific directory where download all necessary files e.g your desktop C:\Users\\%username%\Desktop

```powershel
Set-Location $Env:USERPROFILE\Desktop
```

### 3.3. Pаstе command below into PowerShell prompt

```powershel
Invoke-WebRequest 'https://raw.githubusercontent.com/TheBuggs/Envizimo/main/download.ps1' -OutFile ./download.ps1; .\download.ps1
```

### 3.4. Execute the command

### 3.5. Now you write information for your homepage and bookmark link (Please add https:// before address)

#### 3.5.1 Add link for your homepage e.g. https://google.bg

#### 3.5.2 Add link for your envizimo site e.g. https://my.site.tld

### 3.6. After that wait to download and generete your custom installer... :hourglass:

You can find your installer into "./eventis" folder with 'pack.exe' name. You need only from 'pack.exe', other files is not needed you can delete if you want. Install pack.exe like admin into your machines - click right mouse button over file and choose "Run as administrator" and start process to install all necessery software to your computer. :smirk:

## 4. Demo

## 5. Deploy with SCCM

If you have SCCM in your environment. Create Application with content - all files in ./eventis/data. Task to start install is it a install.ps1 script and for uninstaller execute uninstall.ps1 script.
