####################################################################
# Upgrade Windows 10 to Windows 11 with PowerShell (No Intune, SCCM, or MDT Needed!)
# https://www.youtube.com/@darienstips9409
# Update offline Windows install.wim
####################################################################


# Prepare and get SHA256 HASH of source ISO file
$isoFilePath = "\\dariens.tips\upgrade\ISOFiles"
Get-FileHash $isoFilePath\$isoFileName


# (D)	Upgrade Windows 10 to Windows 11, 25H2
$isoFilePath = "\\dariens.tips\upgrade\ISOFiles"
$destPath = "\\upg01\c$\Temp4W11Upgrade"
# When connected remotely via PSSession or SSH
$destPath = "C:\Temp4W11Upgrade" 

$isoFileName = "SW_DVD9_Win_Pro_11_25H2_64BIT_English_Pro_Ent_EDU_N_MLF_26200-5074.iso"

Robocopy.exe /R:1 /W:2 $isoFilePath $destPath $isoFileName
Get-FileHash $destPath\$isoFileName


# Connect to remote computer and start upgrade
$upg01PSSession = New-PSSession upg01 # Not needed for an ssh session
Enter-PSSession $upg01PSSession # Not needed for an ssh session
Mount-DiskImage C:\Temp4W11Upgrade\SW_DVD9_Win_Pro_11_25H2_64BIT_English_Pro_Ent_EDU_N_MLF_26200-5074.iso
$isoDrive = (Get-DiskImage C:\Temp4W11Upgrade\SW_DVD9_Win_Pro_11_25H2_64BIT_English_Pro_Ent_EDU_N_MLF_26200-5074.iso | Get-Volume).DriveLetter + ":"

$winLogDir = "c:\Windows\Temp\Win11UpgradeLogs"
$eventAppLogName="Windows 11 Upgrade"
New-EventLog -LogName Application -Source $eventAppLogName -ErrorAction SilentlyContinue
New-Item -Type Directory $winLogDir -Force

#Temporarlily disable BitLocker protection for OS drive if enabled
Get-BitLockerVolume -MountPoint C:
Suspend-BitLocker -MountPoint c: -RebootCount 2

$updateStarted="Windows 11 upgrade started"
Write-EventLog -LogName Application -Source $eventAppLogName -EntryType Information -EventId 1000 -Message $updateStarted
Start-Process -FilePath $isoDrive\setup.exe -ArgumentList "/auto upgrade /quiet /eula accept /copylogs $winLogDir" -LoadUserProfile

# (E)	Install Updates Post Upgrade
# Copy update files to remote computer
$updateSourcePath = "\\dariens.tips\upgrade\Updates"
$destPath = "\\upg01\c$\Temp4W11Upgrade"
# When connected remotely via PSSession or SSH
$destPath = "C:\Temp4W11Upgrade"

$kbNum = "KB5065426"
Robocopy.exe /R:1 /W:2 $updateSourcePath\$kbNum $destPath\$kbNum *

# Connect to remote computer and install updates
$upg01PSSession = New-PSSession upg01 # Not needed for an ssh session
Enter-PSSession $upg01PSSession # Not needed for an ssh session
cmd /c ver
$eventAppLogName = "Windows 11 Upgrade"
$osV=(Get-ComputerInfo).osversion
if ($osV -like "*261*") { $OSUpdateCompleted="Windows 11 24H2 upgrade completed (OSVersion: $osV)" } elseif 
    ($osV -like "*262*") { $OSUpdateCompleted="Windows 11 25H2 upgrade completed (OSVersion: $osV)" } else 
    { $OSUpdateCompleted="Windows upgrade completed (OSVersion: $osV)"
}


Write-EventLog -LogName Application -Source $eventAppLogName -EntryType Information -EventId 1001 -Message $OSUpdateCompleted

function updateAndRestart {
    $eventAppLogName = "Windows 11 Upgrade"
    $OSUpdateStarted = "KB5065426 OS update started"
    $netUpdateStarted = "KB5065426 for .NET Framework update started"
    Write-EventLog -LogName Application -Source $eventAppLogName -EntryType Information -EventId 1002 -Message $OSUpdateStarted
    Add-WindowsPackage -Online -PackagePath C:\Temp4W11Upgrade\KB5065426\windows11.0-kb5065426-x64_32b5f85e0f4f08e5d6eabec6586014a02d3b6224.msu -NoRestart
    Write-EventLog -LogName Application -Source $eventAppLogName -EntryType Information -EventId 1003 -Message $netUpdateStarted
    Add-WindowsPackage -Online -PackagePath C:\Temp4W11Upgrade\KB5065426\windows11.0-kb5064401-x64-ndp481_03d42dc42df2db6f1812c2fa3d768780c079a843.msu -NoRestart
    Restart-Computer -Force
}
updateAndRestart


# Verify upgrade and updates installed
# When connected remotely via PSSession or SSH no need for the -session parameter
$upg01PSSession = New-PSSession upg01 #not needed for an ssh session
Invoke-Command -Session $upg01PSSession -ScriptBlock {
    cmd /c ver
    Get-ComputerInfo | Select-Object CsName,OsName,OsVersion,OSDisplayVersion | Format-List
    Get-HotFix | Sort-Object InstalledOn -Descending
    Get-BitLockerVolume -MountPoint C:
    Dismount-DiskImage C:\Temp4W11Upgrade\SW_DVD9_Win_Pro_11_25H2_64BIT_English_Pro_Ent_EDU_N_MLF_26200-5074.iso -ErrorAction SilentlyContinue
}


# Clean up
$destPath = "\\upg01\c$\Temp4W11Upgrade"
# When connected remotely via PSSession or SSH
$destPath = "C:\Temp4W11Upgrade"

Remove-Item -Recurse -Force $destPath

# Re-enable BitLocker protection for OS drive if previously enabled
Get-BitLockerVolume -MountPoint C:
Resume-BitLocker -MountPoint c:









Get-Process -name setup
(Get-Process -name setup).id | ForEach-Object { taskkill /pid $_ /t /f}



Windows11_InsiderPreview_EnterpriseVL_x64_en-us_26200
...renamed to...
SW_DVD9_Win_Pro_11_25H2_64BIT_English_Pro_Ent_EDU_N_MLF_26200-5074






