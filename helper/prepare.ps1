#
# simple script to prepare league skin package

# Stone, 07/2024, info@simracingjustfair.org
#

# Notes

# source variables
. ../variables.ps1

# some folders
if (-not (Test-Path "..\Vehicles")) { New-Item -ItemType Directory -Name ..\Vehicles -Force | out-null }
if (-not (Test-Path "..\Content")) {New-Item -ItemType Directory -Name ..\Content -Force | out-null }
if (-not (Test-Path "..\Log")) {New-Item -ItemType Directory -Name ..\Log -Force | out-null }

# get the foldernames from rFactor2 vehicle folder
$INSTALLED_VEHICLES=((gci -recurse -Path $RF2ROOT\Installed\Vehicles -Directory).Name |select-string -Pattern $VEHICLE_TYPE)

# create the folder structure
forEach ( $FOLDER in $INSTALLED_VEHICLES )
{
 new-item -ItemType Directory -Name $FOLDER -Path ..\Vehicles
}