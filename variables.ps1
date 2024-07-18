# where is rfactor 2 located (currently program files (x86) is not supported)
$RF2ROOT="c:\program files (x86)\steam\steamapps\common\rfactor 2"

# where do we find the downloaded workshop packages
$RF2WORKSHOPPKGS="$RF2ROOT\steamapps\workshop\content\365960"

# as SteamCMD needs to be installed, where to find it
$STEAMINSTALLDIR="$RF2ROOT\steamcmd"

# we need an Steam API key for the DLC installer
$STEAMAPIKEY=""

# DLC installer uses CSV files ...
$CSVCARFILE="$RF2ROOT\dlccars.csv"
$CSVTRACKFILE="$RF2ROOT\dlctracks.csv"
$CSVCONTENTFILE="$RF2ROOT\dlccontent.csv"

# DLC installer uses CSV files ...
$CSVCARFILE="$RF2ROOT\dlccars.csv"
$CSVTRACKFILE="$RF2ROOT\dlctracks.csv"
$CSVCONTENTFILE="$RF2ROOT\dlccontent.csv"

# name of the profile to use (refer to $RF2ROOT\Userdata\<profile>)
# note: can be given as argument on CLI where used in scripts
$PROFILE="player"

# define metadata for Steam Workshop Upload
$METADATACHANGE="SRJF-EXAMPLE-2024"
$METADATADESCR="SRJF Example 2024 Skinpack"
$METADATATITLE="simracingjustfair.org 2024"
$METADATAPREVFILE="preview.jpg"

# rf2_league_pkg_builder
$VEHICLE_TYPE="gt3"