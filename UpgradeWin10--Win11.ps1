####################################################################
# Upgrade Windows 10 to Windows 11 with PowerShell (No Intune, SCCM, or MDT Needed!)
# https://www.youtube.com/@darienstips9409
# Update offline Windows install.wim
####################################################################


# Establish and declare variables
$srcPath="\\share\upgrade\W11Upgrade"
$logPath="\\share\upgrade\UpgradeLogs"
$destPath="C:\Temp\W11Upgrade"
$isDestPathPresent=Test-Path $destPath


# if Destination path is present, delete and create from source to ensure currency
if ($isDestPathPresent) {Remove-Item -Recurse -Force $destPath}


# Create Paths
New-Item -ItemType Directory $destPath -ErrorAction SilentlyContinue


# Copy files to local folder
Robocopy.exe $srcPath $destPath * /E /R:2 /W:2


# Write rudimentary log
$thisIsNow=Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$thisIsNowISO8601=Get-Date -Format yyyyMMddHHmmss
$updateStarted="Windows 11 upgrade started at: $thisIsNow for Computer: $env:COMPUTERNAME"
write-host $updateStarted
$updateStarted | Out-File -Encoding utf8 -Append -FilePath $logPath\$env:COMPUTERNAME-Win11UpgradeStart-$thisIsNowISO8601.txt


# Create an event log entry for the upgrade start
$eventAppLogName="Windows-11_Upgrade"
if (-not [System.Diagnostics.EventLog]::SourceExists($eventAppLogName)) {
    New-EventLog -LogName Application -Source $eventAppLogName
}
Write-EventLog -LogName Application -Source $eventAppLogName -EntryType Information -EventId 1000 -Message $updateStarted


# Start upgrade process if setup is present
if (Test-Path $destPath\setup.exe) {
    Start-Process -FilePath $destPath\setup.exe -ArgumentList "/auto upgrade /quiet /eula accept /dynamicupdate enable /copylogs $logPath"
} else {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] ERROR: setup.exe not found at $destPath" | Out-File -Encoding utf8 -Append -FilePath "$logPath\Win11UpgradeStart.txt"
    Write-Host "setup.exe not found. Upgrade aborted."
}


# Optionally, monitor the upgrade process
while (Get-Process -Name setup) {write-host "Windows 11 Update is proceeding" ; get-date ; sleep -Seconds 5}
