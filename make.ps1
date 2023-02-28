###### STEP 1 - GENERATE CUSTOMIZED MOZZILA FIREFOX INSTALER #####################################################

# ==== CUSTOMIZED DATA ===========================================================================================
Write-Host "#01. Configure custom bookmarks and homepage data..." -ForegroundColor Green
# $HOME_PAGE = "https://google.bg"
# $BOOK_LINK = "https://yoursite.bg"
$HOME_PAGE = Read-Host "Your Default Homepage Link"
$BOOK_LINK = Read-Host "Your Default Eventis Link"

# ==== URLS DOWNLOAD DATA =========================================================================================
Write-Host "#02. Create links array" -ForegroundColor Green
$ESR_EXE = "https://ftp.mozilla.org/pub/firefox/releases/91.13.0esr/win64/en-US/Firefox%20Setup%2091.13.0esr.exe"
$ZIP_EXE = "https://www.7-zip.org/a/7z2107-x64.exe"
$SFX_EXE = "https://hg.mozilla.org/mozilla-central/raw-file/tip/other-licenses/7zstub/firefox/7zSD.Win32.sfx"
$ADDON   = "https://addons.mozilla.org/firefox/downloads/file/3654313/signtextjs_plus-0.9.6-fx.xpi"

# ==== TEMPORARY DIRECTORY =======================================================================================
Write-Host "#03. Create main temporary folder..." -ForegroundColor Green
$SCRIPT_LOCATION = Get-Location
[string]$DRIVE = ($env:windir).Split("\")[0]
[string]$STORE = "{0}\Windows\Temp\EventisRS" -f $DRIVE

if((Test-Path $STORE) -eq $false) { New-Item -Path $STORE -ItemType Directory -Force | Out-Null }

# ==== URL ADDRESSES TO DOWNLOAD SOFTWARE ========================================================================
Write-Host "#04. Make work array data..." -ForegroundColor Green
$URLS = @{
    "firefox.exe" = @{
        "url"  = $ESR_EXE
        "hash" = ""
    }
    "7zip.exe" = @{
        "url"  = $ZIP_EXE
        "hash" = ""
    }
    "7zSD.Win32.sfx" = @{
        "url"  = $SFX_EXE
        "hash" = ""
    }
    "signtextjs_plus-0.9.6-fx.xpi" = @{
        "url"  = $ADDON
        "hash" = ""
    }
}

# ==== EXECUTE DOWNLOAD SOFTWARE TASKS ============================================================================
Write-Host "#05. Start to download nessesery files..." -ForegroundColor Green
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$JOBS = @{}
foreach($NAME in $URLS.Keys) {
    
    $URL = $URLS[$NAME]["url"]
    $DEST = "{0}\{1}" -f $STORE, $NAME
    
    $JOBS[$NAME] = Start-Job -ArgumentList $URL, $DEST -ScriptBlock {
        param($URL=$URL, $DEST=$DEST)
        Invoke-WebRequest -Uri $URL -OutFile $DEST
    }
}

# ==== CHECK EXIST 7-ZIP SOFTWARE =================================================================================
Write-Host "#06. Search 7-zip application..." -ForegroundColor Green
$7ZIP = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
? { $_.DisplayName -Like "7*Zip*"}).InstallLocation

if(!$7ZIP){
        
    $SERACH_PROGRAM = @("Program Files", "Program Files (x86)", "Program Data")
    $7ZIP_EXISTED = $null
        
    foreach ( $ITEM in $SEARCH_PROGRAM ){
        $SEARCH_DIR = "{0}\{1}" -f $DRIVE , $ITEM
        $7ZIP_EXISTED = Get-ChildItem -Path $SEARCH_DIR -Include "7z.exe" -File -Recurse -ErrorAction SilentlyContinue
        if( $7ZIP_EXISTED ){ break }
    }

    if(!$7ZIP_EXISTED.DirectoryName){
        Write-Host "#4. Install 7-zip application..." -ForegroundColor Green
        # == INSTALL 7-ZIP SOFTWARE ==
        Wait-Job $JOBS["7zip.exe"] | Out-Null
        $ERR = (Start-Process -FilePath $STORE\7zip.exe -ArgumentList "/S" -Wait -NoNewWindow -PassThru).ExitCode
            
        if (!$ERR ) {
            $7ZIP = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall \* | 
            ? { $_.DisplayName -like "7*Zip*"}).InstallLocation
        }else{
            $7ZIP = $7ZIP_EXISTED.DirectoryName
        }
    }  
}

if (!$7ZIP) { throw "Please install 7-Zip and try again!"} 
else { $7ZIP = "{0}7z.exe" -f $7ZIP  }

# ==== SEARCH AND REMOVE OLD FIREFOX NON INSTALLER DATA ===========================================================
Wait-Job $JOBS["7zip.exe"] | Out-Null

# ==== SEARCH AND REMOVE OLD FIREFOX NON INSTALLER DATA ===========================================================
Write-Host "#07. Create helpper temp folder..." -ForegroundColor Green
$MODIFY = "{0}\Modify" -f $STORE
if((Test-Path $MODIFY) -eq $false) { New-Item -Path $MODIFY -ItemType Directory -Force | Out-Null }

# ==== UNZIP MOZILLA FIREFOX FILES
Write-Host "#08. Unzipping firefox..." -ForegroundColor Green
Wait-Job $JOBS["firefox.exe"] | Out-Null
Set-Location $STORE | Out-Null
[string]$UNZIP_COMMAND = "`"$7ZIP`" x `"firefox.exe`" -o{0}" -f $MODIFY
& cmd.exe /c $UNZIP_COMMAND | Out-Null

# ==== ADD SETTINGS FOR DISTRIBUTION.INI ==========================================================================
Write-Host "#09. Create distribution.ini file with confiuguration data..." -ForegroundColor Green
Set-Location $MODIFY\core | Out-Null
New-Item -Path $MODIFY\core\distribution -ItemType Directory | Out-Null
$CONTENT_DISTRIBUTION = @"
[Global]
id=eventis-build
version=0.2
about=Customized Eventis

[Preferences]
security.osclientcerts.autoload=false
browser.shell.checkDefaultBrowser=false
browser.tabs.warnOnClose=false
browser.showPersonalToolbar=true
extensions.pocket.enabled=false
general.smoothScroll=false
browser.newtabpage.enhanced=false
network.cookie.cookieBehavior=1
privacy.trackingprotection.enabled=true
privacy.trackingprotection.introCount=20
toolkit.telemetry.enabled=true
browser.crashReports.unsubmittedCheck.autoSubmit=true
datareporting.policy.dataSubmissionPolicyBypassNotification=true
browser.rights.3.shown=true
browser.startup.homepage_override.mstone="ignore"
browser.search.geoSpecificDefaults=false

[LocalizablePreferences]
browser.startup.homepage=$($HOME_PAGE)
"@
 
New-Item "$MODIFY\core\distribution\distribution.ini" -ItemType File -Value $CONTENT_DISTRIBUTION | Out-Null

Set-Location $MODIFY\core\distribution | Out-Null
New-Item -Path $MODIFY\core\distribution\extensions -ItemType Directory | Out-Null
Wait-Job $JOBS["signtextjs_plus-0.9.6-fx.xpi"] | Out-Null
Copy-Item -Path "$STORE\signtextjs_plus-0.9.6-fx.xpi" `
-Destination "$MODIFY\core\distribution\extensions\jid1-FkPKYIvh3ElkQO@jetpack.xpi" | Out-Null

# ==== ADD SETTINGS FOR POLICIES.JSON
Write-Host "#10. Create policy.json file with configuration data..." -ForegroundColor Green

$CONTENT_POLICIES = @"
{
  `"policies`": {
    `"NoDefaultBookmarks`": true,
    `"SecurityDevices`": {
      "eToken`": `"eTPKCS11.dll`"
    },
    `"Certificates`": {
      "ImportEnterpriseRoots`": true
    },
    `"Certificates`": {
      `"Install`": [`"C:\\Program Files\\signtextjs_plus\\StampITGlobalRootCA.crt`", `"C:\\Program Files\\signtextjs_plus\\StampITGlobalQualifiedCA.crt`"]
    },
    `"Bookmarks`": [
      `{
        `"Title`": `"$($BOOK_NAME)`",
        `"URL`": `"$($BOOK_LINK)`",
        `"Favicon`": `"$($BOOK_LINK)/favicon.ico`",
        `"Placement`": `"toolbar`"
      }
    ]
  }
}
"@

New-Item "$MODIFY\core\distribution\policies.json" -ItemType File -Value $CONTENT_POLICIES | Out-Null

# ==== CLEAR DEFAULT BOOKMARKS =====================================================================================
Write-Host "#11. Create default bookmarks.html file..." -ForegroundColor Green
New-Item -Path $MODIFY\core\defaults\profile -ItemType Directory | Out-Null
New-Item "$MODIFY\core\defaults\profile\bookmarks.html" -ItemType File -Value "" | Out-Null

# ==== ZIPPING MODIFIED FILES ======================================================================================
Write-Host "#12. Zipping all fiels..." -ForegroundColor Green
Set-Location $MODIFY | Out-Null
$COMMAND = "`"$7ZIP`" a -r -t7z app.7z -mx -m0=BCJ2 -m1=LZMA:d24 -m2=LZMA:d19 -m3=LZMA:d19 -mb0:1 -mb0s1:2 -mb0s2:3"
& cmd.exe /c $COMMAND | Out-Null

Write-Host "#13. Copy 7zSD.Win32.sfx..." -ForegroundColor Green
Wait-Job $JOBS["7zSD.Win32.sfx"] | Out-Null
Set-Location $STORE | Out-Null
Copy-Item -Path $STORE\7zSD.Win32.sfx -Destination $MODIFY\7zSD.Win32.sfx | Out-Null

# ==== CRETE APP.TAG FILE ==========================================================================================
Write-Host "#14. Create app.tag file..." -ForegroundColor Green
New-Item "$MODIFY\app.tag" -ItemType File -Value `
@"
;!@Install@!UTF-8!
Title=`"Mozilla Firefox`"
RunProgram=`"setup.exe`"
;!@InstallEnd@!
"@ | Out-Null

# == COMBINAE ALL FILE INTO EXE ====================================================================================
Write-Host "#15. Generate EXE Firefox file..." -ForegroundColor Green
Set-Location $MODIFY | Out-Null
$COMBINE_COMMAND = "copy /B 7zSD.Win32.sfx+app.tag+app.7z firefox.exe"
& cmd.exe /c $COMBINE_COMMAND | Out-Null

# == COPY FINAL FILE TO SCRIPT LOCATION ============================================================================
Copy-Item $MODIFY\firefox.exe -Destination $SCRIPT_LOCATION\data\firefox.exe | Out-Null

# == SET SCRIPT LOCATION ===========================================================================================
Set-Location $SCRIPT_LOCATION | Out-Null

# == CLEAR ALL DATA ================================================================================================
Write-Host "#16. Clear work data..." -ForegroundColor Green
if(Test-Path $STORE) {
    Wait-Job $JOBS["signtextjs_plus-0.9.6-fx.xpi"] | Out-Null
    Wait-Job $JOBS["7zip.exe"] | Out-Null
    Wait-Job $JOBS["7zSD.Win32.sfx"] | Out-Null
    Wait-Job $JOBS["firefox.exe"] | Out-Null
    Start-Sleep 3
    # Read-Host -Prompt "Press any key to finish"
    Remove-Item $STORE -Recurse -Force -Verbose | Out-Null
}