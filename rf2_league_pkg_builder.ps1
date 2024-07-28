#
# simple script to build league skin package

# Stone, 07/2024, info@simracingjustfair.org
#

# Notes
#
# "remove" extension from filename
# (gci ./alt061.dds).BaseName
# 	alt061
#
# extracting characters from filename: (gci).BaseName.Substring(0,3)
# getting baseversion ...
# this will do: ((gci -Directory).Name) -match '\d{1,}\.\d{1,}$'| select-object -first 1


# source variables
. ./variables.ps1

if (-not ( "$CURRENTVERSION" )) 
 {
  $CURRENTVERSION=(Get-Date -Format "yyyy.MM.dd")
 }

$CURRENTLOCATION=((Get-Location).Path)

# running prepare.ps1? 
if (-not (Test-Path "$CURRENTLOCATION\\Vehicles" -PathType Container))
 {
  write-host "Please run prepare.ps1."
  timeout /t 10
  exit 1
 }

# arguments given?
if ($args[0]) {
    $COMPONENTS=$args
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

 # this is necessary, because mod building is case sensitive we need the exact component name in rfcmp as in dat file
 write-host "Checking "$COMPONENT

 if ( $COMPONENT -eq  ((gci -Path vehicles).Name|select-string -Pattern "$COMPONENT") )
  {
   $COMPONENT=((gci -Path vehicles).Name|select-string -Pattern "$COMPONENT")
  }
 
 # get the information for the rfcmp from template
 $CMPINFO=(gc $CURRENTLOCATION\vehicle.dat)

 # change rfcmp template
 $CMPINFO=($CMPINFO -replace "^Name=.*","Name=$COMPONENT")
 $CMPINFO=($CMPINFO -replace "^Version=.*","Version=$CURRENTVERSION")

 # this will read the base version ... hopefully
 $BASEVERSION=(((gci $RF2ROOT\Installed\Vehicles\$COMPONENT -Directory).Name) -match '\d{1,}\.\d{1,}$'| sort-object | select-object -first 1)
 $CMPINFO=($CMPINFO -replace "^BaseVersion=.*","BaseVersion=$BASEVERSION")
 $CMPINFO=($CMPINFO -replace "^Location=.*","Location=$CURRENTLOCATION\Content\$RFCMPPREFIX-${COMPONENT}-$CURRENTVERSION.rfcmp")

 # lookup if there is an old mas file in $COMPONENT
 if ( Test-Path "$CURRENTLOCATION\Vehicles\$COMPONENT\$RFCMPPREFIX-skins.mas" ) 
  { 
   del $CURRENTLOCATION\Vehicles\$COMPONENT\$RFCMPPREFIX-skins.mas 
  }

 # is there any other ...?
 $MASFILE=(((gci -Path "$CURRENTLOCATION\Vehicles\$COMPONENT").Name) | select-string -Pattern ".mas")

 # get all files which are in $COMPONENT
 $CHECKFILES=(gci -Path "$CURRENTLOCATION\Vehicles\$COMPONENT")
 
 # if a mas file already exists or not ...
 if ( $MASFILE ) {
    write-host "MAS file found "$MASFILE
    write-host "Building RFCMP for "$COMPONENT

    # arguments for modmgr
    $ARGUMENTS=" -l""$CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE"" ""$CURRENTLOCATION\Log\content-existing-masfile-$COMPONENT-$CURRENTVERSION.txt"" "
    start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow -Wait
    }
 elseif ( $CHECKFILES ) {

    write-host "Packing masfile for RFCMP "$COMPONENT

    # as this is the name of the mas file if we build it ...
    $MASFILE="$RFCMPPREFIX-skins.mas"

    # build argument list for modmgr
    $ARGUMENTS=" -m""$CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE"" ""$CURRENTLOCATION\Vehicles\$COMPONENT\*.json"" ""$CURRENTLOCATION\Vehicles\$COMPONENT\*.dds"" ""$CURRENTLOCATION\Vehicles\$COMPONENT\*.veh"" ""$CURRENTLOCATION\Vehicles\$COMPONENT\*.png"" ""$CURRENTLOCATION\Vehicles\$COMPONENT\*.ini"""
    
    # run modmgr to build mas file
    start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow  -Wait

    write-host "Building RFCMP for "$COMPONENT

    # building arguments to build rfcmp
    $ARGUMENTS=" -l""$CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE"" ""$CURRENTLOCATION\Log\content-generated-masfile-$COMPONENT-$CURRENTVERSION.txt"" "

    # run modmgr to build rfcmp file
    start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow  -Wait
    
 }
 #exit 1

 # change vehicle.dat file to add mas file
 $CMPINFO=($CMPINFO -replace "^MASFile=.*","MASFile=$CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE")

 # remove any previously (old) rfcmps of the component
 $OLDRFCMPS=((gci $CURRENTLOCATION\Content -Name)|select-string -Pattern $COMPONENT)
 
if ( $MASFILE ) {

 if ($OLDRFCMPS){
  forEach($OLDRFCMP in $OLDRFCMPS)
  {
   write-host "Deleting previous version of "$COMPONENT" rfcmp in content folder."
   del -Verbose $CURRENTLOCATION\content\$OLDRFCMP
  }
 }

 #
 write-host "Building RFCMP for "$COMPONENT" with version "$CURRENTVERSION

 # write the rfcmp definition
 $CMPINFO | Out-File "$CURRENTLOCATION\$COMPONENT-$CURRENTVERSION.dat" -Encoding ASCII

 # build argument list for modmgr
 $ARGUMENTS=" -b""$CURRENTLOCATION\$COMPONENT-$CURRENTVERSION.dat"" 0 "
    
 # run modmgr to build rfcmp
 start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow  -Wait

 # delete the vehicle / rfcmp dat file
 #del $CURRENTLOCATION\$COMPONENT.dat

 # move the definition file to log folder
 move-item $CURRENTLOCATION\$COMPONENT-$CURRENTVERSION.dat Log\ -Force

 del $CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE
 }

}

# prepare Steam Workshop Upload
#
# if there is the template ... then ...
 if ( (Test-Path "$CURRENTLOCATION\metadata.tpl" -PathType Leaf) -and (!(Test-Path "$CURRENTLOCATION\metadata.tpl" -PathType Leaf)) ) 
{
 write-host "Using metadata template for metadata.vdf generation."

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
 del $CURRENTLOCATION\metadata.tpl
}

if ( Test-Path "$CURRENTLOCATION\metadata.vdf" -PathType Leaf )
{
 # check if steamcmd is already installed
 if(-not(Test-path "$CURRENTLOCATION\SteamCMD\steamcmd.exe" -PathType leaf))
 {
  write-host "SteamCMD not found - downloading and installing."

  # check for folder and create it if not existing
  if(-not(Test-Path "$CURRENTLOCATION\SteamCMD" -PathType Directory)) { mkdir $CURRENTLOCATION\SteamCMD }

  # download SteamCMD and unpack it
  start-process -FilePath powershell -ArgumentList "Invoke-RestMethod -Uri https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip -OutFile $CURRENTLOCATION\steamcmd.zip" -NoNewWindow -Wait
  start-process -FilePath powershell -ArgumentList "Expand-Archive -Force $CURRENTLOCATION\steamcmd.zip -DestinationPath $CURRENTLOCATION\SteamCMD" -NoNewWindow -Wait
  
  # run it once in order to configure it and check for Steam Guard
  start-process "$CURRENTLOCATION\SteamCMD\steamcmd.exe" -ArgumentList " +quit" -NoNewWindow -Wait

  # remove the downloaded archive
  del $CURRENTLOCATION\steamcmd.zip
 }

 write-host "Uploading files to Steam workshop."

 # building arguments for SteamCMD call ... remember to register the system with Steam guard code if configured (2FA)
 $ARGUMENTS=" +login ""$STEAMUSER"" ""$STEAMPASSWORD"" +workshop_build_item $CURRENTLOCATION\metadata.vdf +quit"
 
  # call Steamcmd and upload the stuff
 if ( ($STEAMUPLOAD -eq "true") -and ($STEAMUSER -ne "changeme") -and ($STEAMPASSWORD -ne "changeme") ) {
  # would we avoid PHP timeout if -Wait is being removed?
  start-process -FilePath "$CURRENTLOCATION\SteamCMD\SteamCMD.exe" -ArgumentList $ARGUMENTS # -NoNewWindow -Wait
 } 

}
else 
{ 
 write-host "metadata.vdf missing for Steam workshop upload."
}
