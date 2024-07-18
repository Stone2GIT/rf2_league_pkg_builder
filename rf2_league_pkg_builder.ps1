#
# simple script to build league skin package

# Stone, 07/2024, info@simracingjustfair.org
#

# Notes

# source variables
. ./variables.ps1

$CURRENTVERSION=(Get-Date -Format "yyyy.MM.dd")
$CURRENTLOCATION=((Get-Location).Path)

# some folders
New-Item -ItemType Directory -Name Vehicles -Force | out-null
New-Item -ItemType Directory -Name Content -Force | out-null


if ($args[0]) {
    $COMPONENTS=$args[0]
    }
    else {
        # read in components from vehicles
        $COMPONENTS=((gci -Path Vehicles).Name)
    }


if ( $COMPONENTS -eq "" ) {
    write-host "Please copy folders and files to VEHICLES."
    exit 1
    }

# what to do ...
forEach ($COMPONENT in $COMPONENTS)
{

 #write-host "Building "$COMPONENT

 # get the information for the rfcmp from template
 $CMPINFO=(gc $CURRENTLOCATION\vehicle.dat)

 # change rfcmp template
 $CMPINFO=($CMPINFO -replace "^Name=.*","Name=$COMPONENT")
 $CMPINFO=($CMPINFO -replace "^Version=.*","Version=$CURRENTVERSION")

 # this will read the base version ... hopefully
 $BASEVERSION=((gci $RF2ROOT\Installed\Vehicles\$COMPONENT).Name|sort-object|select -first 1)
 $CMPINFO=($CMPINFO -replace "^BaseVersion=.*","BaseVersion=$BASEVERSION")
 $CMPINFO=($CMPINFO -replace "^Location=.*","Location=$CURRENTLOCATION\Content\SRC-${COMPONENT}-$CURRENTVERSION.rfcmp")

 # lookup mas file in $COMPONENT
 if ( Test-Path $CURRENTLOCATION\Vehicles\$COMPONENT\car-skins.mas ) { del $CURRENTLOCATION\Vehicles\$COMPONENT\car-skins.mas }
 $MASFILE=(((gci -Path $CURRENTLOCATION\Vehicles\$COMPONENT).Name) | select-string -Pattern ".mas")

 $CHECKFILES=(gci -Path $CURRENTLOCATION\Vehicles\$COMPONENT)
 
 # if a mas file already exists or not ...
 if ( $MASFILE ) {
    write-host "MAS file found "$MASFILE

    $ARGUMENTS=" -l""$CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE"" ""$CURRENTLOCATION\Log\content-existing-masfile-$COMPONENT-$CURRENTVERSION.txt"" "
    start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow -Wait
    }
 elseif ( $CHECKFILES ) {
    # c:\Users\rfactor2\rf2ds\bin64\ModMgr.exe -m"car-skins.mas" *.json *.dds *.veh *.png *.ini

    write-host "Erstelle masfile fuer RFCMP "$COMPONENT

    # build argument list for modmgr
    $ARGUMENTS=" -m""$CURRENTLOCATION\Vehicles\$COMPONENT\car-skins.mas"" ""$CURRENTLOCATION\Vehicles\$COMPONENT\*.json"" ""$CURRENTLOCATION\Vehicles\$COMPONENT\*.dds"" ""$CURRENTLOCATION\Vehicles\$COMPONENT\*.veh"" ""$CURRENTLOCATION\Vehicles\$COMPONENT\*.png"" ""$CURRENTLOCATION\Vehicles\$COMPONENT\*.ini"""
    
    # run modmgr to build rfcmp
    start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow  -Wait

    $MASFILE="car-skins.mas"

    $ARGUMENTS=" -l""$CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE"" ""$CURRENTLOCATION\Log\content-generated-masfile-$COMPONENT-$CURRENTVERSION.txt"" "
    start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow  -Wait
    
 }

 # write-host "Contents of "$MASFILE
 # gc $CURRENTLOCATION\$COMPONENT.txt
 # del $CURRENTLOCATION\$COMPONENT.txt

 # change vehicle.dat file to add mas file
 $CMPINFO=($CMPINFO -replace "^MASFile=.*","MASFile=$CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE")

 if ( $MASFILE ) {

 # remove any previously (old) rfcmps of the component
 if ( "content\$($COMPONENT)*.rfcmp" )
 {
  write-host "Lösche vorhergehende Version von "$COMPONENT" in Content Verzeichnis."
  del $CURRENTLOCATION\content\$COMPONENT"*.rfcmp"
 }

 #
 write-host "Erstelle RFCMP fuer "$COMPONENT" mit Version "$CURRENTVERSION

 # write the rfcmp definition
 $CMPINFO | Out-File "$CURRENTLOCATION\$COMPONENT-$CURRENTVERSION.dat" -Encoding ASCII

 # build argument list for modmgr
 $ARGUMENTS=" -b""$CURRENTLOCATION\$COMPONENT-$CURRENTVERSION.dat"" 0 "
    
 # run modmgr to build rfcmp
 start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow  -Wait

 # delete the vehicle / rfcmp dat file
 #del $CURRENTLOCATION\$COMPONENT.dat
 move-item $CURRENTLOCATION\$COMPONENT-$CURRENTVERSION.dat Log\ -Force

 del $CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE
 }

}

# prepare Steam Workshop Upload
#
# if there is the template ... then ...
if ( "$CURRENTLOCATION\metadata.tpl" )
{

 write-host "using Metadata template"

 # read in metadata template
 $METADATAINFO=(gc $CURRENTLOCATION\metadata.tpl)

 # change the metadata template
 $METADATAINFO=($METADATAINFO -replace """contentfolder"".*","""contentfolder"" ""$CURRENTLOCATION\Content""")
 $METADATAINFO=($METADATAINFO -replace """changenote"".*","""changenote"" ""$CURRENTVERSION""")
 $METADATAINFO=($METADATAINFO -replace """description"".*","""description"" ""$METADATADESCR""")
 $METADATAINFO=($METADATAINFO -replace """title"".*","""title"" ""$METADATATITLE""")
 $METADATAINFO=($METADATAINFO -replace """previewfile"".*","""previewfile"" ""$CURRENTLOCATION\$METADATAPREVFILE""")

 # write back template
 $METADATAINFO | Out-File "$CURRENTLOCATION\metadata.vdf" -Encoding ASCII
 del 
}

if ( "$CURRENTLOCATION\metadata.vdf" )
{

 write-host "Upload Steam Workshop"

 # SteamCMD call ... remember to register the system with Steam auth code if configured (2FA)
 $ARGUMENTS=" +login loginname ""password"" +workshop_build_item $CURRENTLOCATION\metadata.vdf +quit"
 
 #start-process -FilePath "$CURRENTLOCATION\SteamCMD\SteamCMD.exe" -ArgumentList $ARGUMENTS -NoNewWindow -Wait
}
else 
{ write-host "metadata.vdf missing for Steam workshop upload" }