####################################################################
# Upgrade Windows 10 to Windows 11 with PowerShell (No Intune, SCCM, or MDT Needed!)
# https://www.youtube.com/@darienstips9409
# Update offline Windows install.wim
####################################################################


# Declars vars
$wimImagePth="C:\Temp\W11Upgrade"
$winMountPth="C:\Temp\WinMount"
$msuUpdatePath="C:\Temp\W11KBUpdates"
$msuUpdates="windows11.0-kb5056579-x64-ndp481_a062e62bdedd9a2a4b0cbf4e26ff1652a240f1ee.msu","windows11.0-kb5063878-x64_c2d51482402fd8fc112d2c022210dd7c3266896d.msu"


# Get the image index for Windows 11 and mount it
Get-WindowsImage -ImagePath "$wimImagePth\sources\install.wim"
Mount-WindowsImage -ImagePath "$wimImagePth\install.wim" -Index 3 -Path $winMountPth


# Apply offline updates
foreach ($curMsuUpd in $msuUpdates) {
    Dism /image:$winMountPth /add-package /packagepath:"$msuUpdatePath\$curMsuUpd"
}


#...or use Add-WindowsPackage cmdlet
foreach ($curMsuUpd in $msuUpdates) {
    # Dism /image:$winMountPth /add-package /packagepath:"$msuUpdatePath\$curMsuUpd"
    Add-WindowsPackage -Path $winMountPth -PackagePath "$msuUpdatePath\$curMsuUpd" -PreventPending
}


# Dismount the mounted folder, saving back to install.wim
Dismount-WindowsImage -Path $winMountPth -Save
