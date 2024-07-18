#
# simple script to prepare league skin package

# Dietmar Stein, 07/2024, info@simracingjustfair.org
#

# Notes

# source variables
. ./variables.ps1

# some folders
New-Item -ItemType Directory -Name Vehicles -Force
New-Item -ItemType Directory -Name Content -Force

#
$INSTALLED_GT3=((gci -recurse -Path $RF2ROOT\Installed\Vehicles -Directory).Name |select-string -Pattern GT3)

forEach ( $FOLDER in $INSTALLED_GT3 )
{
 new-item -ItemType Directory -Name $FOLDER -Path Vehicles
} 