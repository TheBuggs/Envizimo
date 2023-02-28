# =============================================== DIRECTORY ======================================================
$SCRIPT_LOCATION = Get-Location
[string]$DRIVE 	 = ($env:windir).Split("\")[0]
[string]$STORE	 = "./"

# ======================================= REMOVE MOZILLA FIREFOX =================================================
$SEARCH = '*Firefox*'

$INSTALLED = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, UninstallString

$INSTALLED += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, UninstallString

$RESULT_FIREFOX = $INSTALLED | ?{ $_.DisplayName -ne $null } | Where-Object {$_.DisplayName -like $SEARCH } 

Write-Host "####################################################" -ForegroundColor Green

if ($RESULT_FIREFOX.uninstallstring -like "msiexec*") {

  $ARGS=(($RESULT_FIREFOX.UninstallString -split ' ')[1] -replace '/I','/X ') + ' /q'
  $ERR = (Start-Process msiexec.exe -ArgumentList $ARGS -Wait -NoNewWindow).ExitCode
    if($ERR){ Write-Host ("Error:    {0}" -f $ERR) -ForegroundColor Red }

} else {

   if($RESULT_FIREFOX){
       [string]$UNINSTALL_COMMAND=(($RESULT_FIREFOX.UninstallString -split '"')[1])
       $UNINSTALL_ARGS=(($RESULT_FIREFOX.UninstallString -split '"')[2]) + ' /S'
       $ERR = (Start-Process $UNINSTALL_COMMAND -ArgumentList $UNINSTALL_ARGS -Wait).ExitCode
		if($ERR){ Write-Host ("Error:    {0}" -f $ERR) -ForegroundColor Red }
    }
}

# ======================================= REMOVE APPDATA PROFILES ===============================================
[string]$PATH = "{0}\Users" -f $DRIVE
$USERS = Get-ChildItem -Path $PATH -Directory

foreach($USER in $USERS) {

    [string]$REMOVE_APPDATA_USERPROFILES = "{0}\{1}\AppData\Roaming\Mozilla" -f $PATH, $USER
    [string]$REMOVE_APPDATA_LOWPROFILE = "{0}\{1}\AppData\LocalLow\Mozilla" -f $PATH, $USER
    [string]$REMOVE_APPDATA_LOCALPROFILES = "{0}\{1}\AppData\Local\Mozilla\Firefox\Profiles" -f $PATH, $USER

    if(Test-Path $REMOVE_APPDATA_USERPROFILES){
        Remove-Item $REMOVE_APPDATA_USERPROFILES -Recurse -Force
        Write-Host "Removed: " $REMOVE_APPDATA_USERPROFILES -ForegroundColor Red
    }

    if(Test-Path $REMOVE_APPDATA_LOWPROFILE){
        Remove-Item $REMOVE_APPDATA_LOWPROFILE -Recurse -Force
        Write-Host "Removed: " $REMOVE_APPDATA_LOWPROFILE -ForegroundColor Red
    }

    if(Test-Path $REMOVE_APPDATA_LOCALPROFILES){
       Remove-Item $REMOVE_APPDATA_LOCALPROFILES -Recurse -Force
       Write-Host "Removed: " $REMOVE_APPDATA_LOCALPROFILES -ForegroundColor Red
    }
}

# ============================= REMOVE IF EXIST OLD SIGNTEXTJS ==================================================
$SIGNTEXTJS_PLUS = "$DRIVE\Program Files\signtextjs_plus"
if( (Test-Path $SIGNTEXTJS_PLUS -PathType Container) -eq $true) {
    Remove-Item $SIGNTEXTJS_PLUS -Recurse
    Write-Host "Remove: " $SIGNTEXTJS_PLUS -ForegroundColor Red
}

# ============================= REMOVE IF EXIST OLD FIREFOX NON INSTALLER DATA ==================================
$FOLDER_PROGRAMFILESx86 = "$DRIVE\Program Files (x86)\Firefox"
if( (Test-Path $FOLDER_PROGRAMFILESx86 -PathType Container) -eq $true) {
    Remove-Item $FOLDER_PROGRAMFILESx86 -Recurse
    Write-Host "Remove: " $FOLDER_PROGRAMFILESx86 -ForegroundColor Red
}

$FOLDER_PROGRAMFILES = "$DRIVE\Program Files\Firefox"
if( (Test-Path $FOLDER_PROGRAMFILES -PathType Container) -eq $true) {
    Remove-Item $FOLDER_PROGRAMFILES -Recurse
    Write-Host "Remove: " $FOLDER_PROGRAMFILES -ForegroundColor Red
}

# ============================= REMOVE MOZZILA INTSALL DATA  ====================================================
$FOLDER_PROGRAMFILESx86_MOZILLA = "$DRIVE\Program Files (x86)\Mozilla Firefox"
if( (Test-Path $FOLDER_PROGRAMFILESx86_MOZILLA -PathType Container) -eq $true) {
    Remove-Item $FOLDER_PROGRAMFILESx86_MOZILLA -Recurse
    Write-Host "Remove: " $FOLDER_PROGRAMFILESx86_MOZILLA -ForegroundColor Red
}

$FOLDER_PROGRAMFILES_MOZZILA = "$DRIVE\Program Files\Mozilla Firefox"
if( (Test-Path $FOLDER_PROGRAMFILES_MOZZILA -PathType Container) -eq $true) {
    Remove-Item $FOLDER_PROGRAMFILES_MOZZILA -Recurse
    Write-Host "Remove: " $FOLDER_PROGRAMFILES_MOZZILA -ForegroundColor Red
}

# ==================================== CHECK MSI INSTALLER ======================================================
if((Test-Path "HKLM:Software\Policies\Microsoft\Windows\Installer") -eq $true){
    try{
        if(Get-ItemProperty -Path "HKLM:Software\Policies\Microsoft\Windows\Installer" -Name "DisableMSI" -ea "1") {
             Set-ItemProperty -Path "HKLM:Software\Policies\Microsoft\Windows\Installer" -Name "DisableMSI" -Value "0" -ErrorAction Continue
        }
    }catch{  Write-Host "Message: [$($_.Exception.Message)]" -ForegroundColor Red}
}

Write-Host "####################################################" -ForegroundColor Green
Set-Location $SCRIPT_LOCATION