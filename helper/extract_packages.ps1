 #
# simple script to extract mas files in order to prepare COMPONENT in VEHICLES folder
#
# Stone, 07/2024, info@simracingjustfair.org
#

. ../variables.ps1

# store the current date with month and day in numeric format
$CURRENTDATE=(Get-Date -Format "yy.MMdd")

# pwd ...
$CURRENTLOCATION=((Get-Location).Path)

# get the folder names
$VEHICLEFOLDERS=((Get-ChildItem $RF2ROOT\Installed\Vehicles).Name |select-string -Pattern $VEHICLE_TYPE)

forEach ($VEHICLEFOLDER in $VEHICLEFOLDERS)
 {
  # get the folders' names
  $VEHICLEINSTALLEDVERSION=(((Get-ChildItem $RF2ROOT\Installed\Vehicles\$VEHICLEFOLDER\ -Dir | sort-object LastWriteTime | select-object -Last 1).BaseName)|select-string -Pattern $CURRENTVERSIONPREFIX)

  # look for .mas files in each VEHICLEFOLDER
  $MASFILES=(Get-ChildItem "$RF2ROOT\Installed\Vehicles\$VEHICLEFOLDER\$VEHICLEINSTALLEDVERSION\*.mas")

  forEach ($MASFILE in $MASFILES)
   {
    # we need to remove path helper from CURRENTLOCATION
    $CURRENTLOCATION=($CURRENTLOCATION -replace "\\helper","")
    
    # building argument list
    $ARGUMENTS=" *.* -x""$MASFILE"" -o""$CURRENTLOCATION\Vehicles\$VEHICLEFOLDER"" "
    
    write-host "Extracting "$MASFILE" to "$CURRENTLOCATION"\Vehicles\"$VEHICLEFOLDER

    # extract all files from masfile to $COMPONENT directory
    start-process "$RF2ROOT\bin64\modmgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow -Wait
   }
 }
