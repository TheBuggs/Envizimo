###### STEP 2 - GENERATE INSTALLER WITH ALL NESSESERY SOFTWARE #####################################################

Write-Host "#02. Create links array" -ForegroundColor Green
$ZIP_EXE = "https://www.7-zip.org/a/7z2107-x64.exe"
$SFX_EXE = "https://hg.mozilla.org/mozilla-central/raw-file/tip/other-licenses/7zstub/firefox/7zSD.Win32.sfx"

# ==== TEMPORARY DIRECTORY =========================================================================================
Write-Host "#01. Create main temporary folder..." -ForegroundColor Green
$SCRIPT_LOCATION = Get-Location
[string]$DRIVE = ($env:windir).Split("\")[0]
[string]$STORE = "{0}\Windows\Temp\EventisRSS" -f $DRIVE

if((Test-Path $STORE) -eq $false) { New-Item -Path $STORE -ItemType Directory -Force | Out-Null }

# ==== URL ADDRESSES TO DOWNLOAD SOFTWARE ==========================================================================
Write-Host "#02. Make work array data..." -ForegroundColor Green
$URLS = @{
    "7zip.exe" = @{
        "url"  = $ZIP_EXE
        "hash" = ""
    }
    "7zSD.Win32.sfx" = @{
        "url"  = $SFX_EXE
        "hash" = ""
    }
}

# ==== EXECUTE DOWNLOAD SOFTWARE TASKS ==============================================================================
Write-Host "#03. Start to download nessesery files..." -ForegroundColor Green
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

# ==== CHECK EXIST 7-ZIP SOFTWARE ===================================================================================
Write-Host "#04. Search 7-zip application..." -ForegroundColor Green
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
        Write-Host "#05. Install 7-zip application..." -ForegroundColor Green
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

# ==== SEARCH AND REMOVE OLD FIREFOX NON INSTALLER DATA ============================================================
Wait-Job $JOBS["7zip.exe"] | Out-Null

# ==== ZIPPING MODIFIED FILES ======================================================================================
Write-Host "#06. Zipping all fiels..." -ForegroundColor Green
Set-Location $SCRIPT_LOCATION\data | Out-Null
$COMMAND = "`"$7ZIP`" a -r -t7z app.7z -mx -m0=BCJ2 -m1=LZMA:d24 -m2=LZMA:d19 -m3=LZMA:d19 -mb0:1 -mb0s1:2 -mb0s2:3"
& cmd.exe /c $COMMAND | Out-Null

# ==== SEARCH AND REMOVE OLD FIREFOX NON INSTALLER DATA ============================================================
Write-Host "#07. Create helpper temp folder..." -ForegroundColor Green
$MODIFY = "{0}\Modify" -f $STORE
if((Test-Path $MODIFY) -eq $false) { New-Item -Path $MODIFY -ItemType Directory -Force | Out-Null }
Copy-Item -Path $SCRIPT_LOCATION\data\app.7z -Destination $MODIFY\app.7z | Out-Null
Remove-Item $SCRIPT_LOCATION\data\app.7z -Force -Verbose | Out-Null
Write-Host "#08. Copy 7zSD.Win32.sfx..." -ForegroundColor Green
Wait-Job $JOBS["7zSD.Win32.sfx"] | Out-Null
Set-Location $STORE | Out-Null
Copy-Item -Path $STORE\7zSD.Win32.sfx -Destination $MODIFY\7zSD.Win32.sfx | Out-Null

# ==== CRETE CONFIG.TXT FILE =======================================================================================
Write-Host "#14. Create config.txt file..." -ForegroundColor Green
New-Item "$MODIFY\config.txt" -ItemType File -Value `
@"
;!@Install@!UTF-8!
Title=`"ENVIZIMO PACK V1.0.0`"
BeginPrompt=`"Do you want to install ENVIZIMO PACK V1.0.0.0?`"
RunProgram=`"install.cmd`"
;!@InstallEnd@!
"@ | Out-Null

# == COMBINAE ALL FILES INTO ONE EXECUTABLE ========================================================================
Write-Host "#15. Generate EXE Firefox file..." -ForegroundColor Green
Set-Location $MODIFY | Out-Null
$COMBINE_COMMAND = "copy /B 7zSD.Win32.sfx+config.txt+app.7z pack.exe"
& cmd.exe /c $COMBINE_COMMAND | Out-Null

# == COPY FINAL FILE TO SCRIPT LOCATION ============================================================================
Copy-Item $MODIFY\pack.exe -Destination $SCRIPT_LOCATION\pack.exe | Out-Null

# == SET SCRIPT LOCATION ===========================================================================================
Set-Location $SCRIPT_LOCATION | Out-Null

# == CLEAR ALL DATA ================================================================================================
Write-Host "#16. Clear work data..." -ForegroundColor Green
if(Test-Path $STORE) {
    Wait-Job $JOBS["7zip.exe"] | Out-Null
    Wait-Job $JOBS["7zSD.Win32.sfx"] | Out-Null
    Start-Sleep 3
    Read-Host -Prompt "Press any key to finish"
    Remove-Item $STORE -Recurse -Force -Verbose | Out-Null
}