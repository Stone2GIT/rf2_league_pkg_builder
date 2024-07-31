# where is rfactor 2 located (currently program files (x86) is not supported)
$RF2ROOT="$HOME\rf2ds"

# define metadata for Steam Workshop Upload
$METADATACHANGE="SRJF-EXAMPLE-2024"
$METADATADESCR="SRJF Example 2024 Skinpack"
$METADATATITLE="simracingjustfair.org 2024"
$METADATAPREVFILE="preview.jpg"

# what type of vehicle to look for in $RF2ROOT\Installed\Vehicles
$VEHICLE_TYPE="gt3"

# automatic SteamUpload, change ALL parameters
$STEAMUPLOAD="false"
$STEAMUSER="changeme"
$STEAMPASSWORD="changeme"

# prefix for rfcmp files (will be $PREFIX-$COMPONENT-$CURRENTVERSION.rfcmp)
$RFCMPPREFIX="SRC"

#
$CURRENTVERSIONPREFIX="3.61-GTW24-"
$CURRENTVERSIONTAG=(Get-Date -Format "yyMMdd")

# version for packages - if left blank todays date will be used
$CURRENTVERSION="$CURRENTVERSIONPREFIX"+"$CURRENTVERSIONTAG"
