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

# =================================== INSTALL MSI CSSI SOFTWARE ==================================================
Write-Host "Install: CSSI ..." -ForegroundColor Green
$MSI = "$DRIVE\Windows\system32\msiexec.exe"
$FILE_CSSI = "cssi.msi"
$ARGS = @("/i", $FILE_CSSI, "/qn", "/norestart")
$ERR = (Start-Process -FilePath $MSI -WorkingDirectory $SCRIPT_LOCATION -ArgumentList $ARGS -Wait -Verb RunAs -PassThru).ExitCode
if($ERR){ Write-Host ("Error:   {0}" -f $ERR) -ForegroundColor Red }

# =================================== INSTALL MSI AWP SOFTWARE ==================================================
Write-Host "Install: AWP ..." -ForegroundColor Green
$MSI = "$DRIVE\Windows\system32\msiexec.exe"
$FILE_AWP = "awp.msi"
$ARGS = @("/i", $FILE_AWP, "/qn", "/norestart")
$ERR = (Start-Process -FilePath $MSI -WorkingDirectory $SCRIPT_LOCATION -ArgumentList $ARGS -Wait -Verb RunAs -PassThru).ExitCode
if($ERR){ Write-Host ("Error:   {0}" -f $ERR) -ForegroundColor Red }

# =================================== INSTALL DSTOOL SOFTWARE ==================================================
Write-Host "Install: DSTool 2.1 Software ..." -ForegroundColor Green

$FILE_DSTOOL = "{0}\dstool.exe" -f $STORE
$ERR = (Start-Process $FILE_DSTOOL  -ArgumentList "/S" -Verb RunAs -Wait -PassThru).ExitCode
if($ERR){ Write-Host ("Error:   {0}" -f $ERR) -ForegroundColor Red}

# =============================== INSTALL CUSTOM MOZILLA FIREFOX ================================================
Write-Host "Install: Mozilla Firefox Software ..." -ForegroundColor Green
$FILE_FIREFOX = "{0}\firefox.exe" -f $STORE
$INSTALL_ARGS = "/S"
$ERR = (Start-Process $FILE_FIREFOX -ArgumentList $INSTALL_ARGS -Wait -NoNewWindow -PassThru).ExitCode
if($ERR){ Write-Host ("Error:   {0}" -f $ERR) -ForegroundColor Red }

# =================================== INSTALL MODIFIED SIGNTEXTJS.EXE  ==========================================
Write-Host "Install: Sign Text JS Software ..." -ForegroundColor Green
$FILE_SIGNTEXTJS = "{0}\signtextjs.exe" -f $STORE
&$FILE_SIGNTEXTJS /s

# ============================= INSTALL MSI STAMPIT-GEMALATO-CLIENT.MSI =========================================
Write-Host "Install: Gemalato Client ..." -ForegroundColor Green
[string]$MSI = "$DRIVE\Windows\system32\msiexec.exe"
[string]$FILE_GEMAILTO = "gemalto.msi"
$ARGS = @("/i", $FILE_GEMAILTO, "/qn", "/norestart")
$ERR = (Start-Process -FilePath $MSI -WorkingDirectory $SCRIPT_LOCATION -ArgumentList $ARGS -Verb RunAs -Wait -PassThru ).ExitCode
if($ERR){ Write-Host ("Error:   {0}" -f $ERR) -ForegroundColor Red }

# ==================================== IMPORT CERTIFICATES CHAIN=================================================
Write-Host "Import:  Certificate chains ..." -ForegroundColor Green
$RUN_CHAIN = '{0}\chains.exe' -f $STORE
$ERR = (Start-Process -FilePath $RUN_CHAIN -Verb RunAs -Wait).ExitCode
if($ERR){ Write-Host ("Error:   {0}" -f $ERR) -ForegroundColor Red }

# ==================================== IMPORT CSSI CERTIFICATES =================================================
$C1 = "$STORE\StampIT_Primary_Root_CA_base64.cer"
$C2 = "$STORE\StampIT_Qualified_CA_base64.cer"
$C3 = "$STORE\StampITGlobalQualifiedCA.cacert.cer"
$C4 = "$STORE\StampITGlobalRootCA.cacert.cer"

Import-Certificate -FilePath $C1 -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
Import-Certificate -FilePath $C2 -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
Import-Certificate -FilePath $C3 -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
Import-Certificate -FilePath $C4 -CertStoreLocation Cert:\LocalMachine\Root | Out-Null

# ==================================== IMPORT CERTIFICATES ======================================================
Write-Host "Import:  Firefox Certificates  ..." -ForegroundColor Green
$CERT1 = "{0}\StampITGlobalRootCA.crt" -f $STORE
$CERT2 = "{0}\StampITGlobalQualifiedCA.crt" -f $STORE
Import-Certificate -FilePath $CERT1 -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
Import-Certificate -FilePath $CERT2 -CertStoreLocation Cert:\LocalMachine\Root | Out-Null

# ============================ COPY CERTIFICATES USE FROM POLICY.JSON ===========================================
Write-Host "Move:    Certificates to signtextjs_plus folder ..." -ForegroundColor Green
$CERTDEST1 = "{0}\StampITGlobalRootCA.crt" -f $SIGNTEXTJS_PLUS
$CERTDEST2 = "{0}\StampITGlobalQualifiedCA.crt" -f $SIGNTEXTJS_PLUS
Copy-Item $CERT1 -Destination $CERTDEST1 | Out-Null
Copy-Item $CERT2 -Destination $CERTDEST2 | Out-Null

# ======================================= RUN REG FILE ==========================================================
Write-Host "Configure: MS Office..." -ForegroundColor Green
$ERR = (Start-Process -Filepath "$DRIVE\Windows\regedit.exe" -ArgumentList "/s", "$STORE\msoffice.reg" -Verb RunAs -Wait -PassThru).ExitCode
if($ERR){ Write-Host ("Error:   {0}" -f $ERR) -ForegroundColor Red }

# ================= ADD URL RECORD TO TRUSTED SITES IN INTERNET OPTIONS TO MACHINE ==============================
Write-Host "Configure: Trusted zone..." -ForegroundColor Green
$ERR = (Start-Process -Filepath "$DRIVE\Windows\regedit.exe" -ArgumentList "/s", "$STORE\trusted.reg" -Verb RunAs -Wait -PassThru).ExitCode
if($ERR){ Write-Host ("Error:   {0}" -f $ERR) -ForegroundColor Red }

# ================= FIXJSON FILE PATH ==============================
(Get-Content "C:\Program Files\signtextjs_plus\signtextjs_plus.json") | 
ForEach {$_ -Replace '"path": "signtextjs_plus.exe",','"path": "C:\\Program Files\\signtextjs_plus\\signtextjs_plus.bat",'} |
Set-Content "C:\Program Files\signtextjs_plus\signtextjs_plus.json"

# ============================================== CLEAR DATA =====================================================
Write-Host "####################################################" -ForegroundColor Green
Set-Location $SCRIPT_LOCATION