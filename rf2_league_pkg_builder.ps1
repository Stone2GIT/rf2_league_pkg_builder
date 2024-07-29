#
# simple script to build league skin package

# Stone, 07/2024, info@simracingjustfair.org
#

# Notes
#
# this will extract the filenames for checksums.txt
# $CHECKSUMS=(get-content checksums.txt)
# forEach ($CHECKSUM in $CHECKSUMS) 
#  { $FILENAME=(($CHECKSUM) -split('=') | select-object -First 1) 
#    if ($SKINFILES -contains $FILENAME) 
#     { write-host "Hello" }
#  }

#
# thinking ... Set-Content -Path "C:\temp\Newtext.txt" -Value (get-content -Path "c:\Temp\Newtext.txt" | Select-String -Pattern 'H\|159' -NotMatch)

# we need this for UNiX time in seconds
[DateTimeOffset]::Now.ToUnixTimeSeconds()

# source variables
. ./variables.ps1

# if CURRENTVERSION is not defined in variables.ps1
if (-not ( "$CURRENTVERSION" )) 
 {
  $CURRENTVERSION=(Get-Date -Format "yyyyMMdd")
 }

# get working directiry
$CURRENTLOCATION=((Get-Location).Path)

# has  prepare.ps1 been run?
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
        $COMPONENTS=((Get-ChildItem -Path Vehicles).Name)
    }

# if we cannot find any components
if ( $COMPONENTS -eq "" ) {
    write-host "Please copy folders and files to VEHICLES."
    exit 1
    }

# what to do with each component found
forEach ($COMPONENT in $COMPONENTS)
{

 write-host "Checking "$COMPONENT

 # this is necessary, because mod building is case sensitive we need the exact component name in rfcmp as in dat file
 if ( $COMPONENT -eq  ((Get-ChildItem -Path vehicles).Name|select-string -Pattern "$COMPONENT") )
  {
   $COMPONENT=((Get-ChildItem -Path vehicles).Name|select-string -Pattern "$COMPONENT")
  }
 
 # get the information for the rfcmp from template
 $CMPINFO=(get-content $CURRENTLOCATION\vehicle.dat)

 # change rfcmp template
 $CMPINFO=($CMPINFO -replace "^Name=.*","Name=$COMPONENT")
 $CMPINFO=($CMPINFO -replace "^Version=.*","Version=$CURRENTVERSION")

 # set UNiX timestamp / date
 $UNIXTIME=(([DateTimeOffset](Get-Date)).ToUnixTimeSeconds())
 $CMPINFO=($CMPINFO -replace "^Date=.*","Date=$UNIXTIME")


 # this will read the base version from component directory ... hopefully
 $BASEVERSION=(((Get-ChildItem $RF2ROOT\Installed\Vehicles\$COMPONENT -Directory).Name) -match '\d{1,}\.\d{1,}$'| sort-object | select-object -first 1)

 # change vehicle.dat
 $CMPINFO=($CMPINFO -replace "^BaseVersion=.*","BaseVersion=$BASEVERSION")
 $CMPINFO=($CMPINFO -replace "^Location=.*","Location=$CURRENTLOCATION\Content\$RFCMPPREFIX-${COMPONENT}-$CURRENTVERSION.rfcmp")

 # lookup if there is an old mas file in $COMPONENT
 if ( Test-Path "$CURRENTLOCATION\Vehicles\$COMPONENT\$RFCMPPREFIX-skins.mas" ) 
  { 
   remove-item $CURRENTLOCATION\Vehicles\$COMPONENT\$RFCMPPREFIX-skins.mas 
  }

 # is there any other ...?
 $MASFILE=(((Get-ChildItem -Path "$CURRENTLOCATION\Vehicles\$COMPONENT").Name) | select-string -Pattern ".mas")

 # if a mas file already exists we will extract it in order to do a default named masfile
 if ( $MASFILE ) {
    write-host "MAS file found "$MASFILE
    write-host "Extracting for "$COMPONENT

    # arguments for extraction
    $ARGUMENTS=" *.* -x""$CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE"" -o""$CURRENTLOCATION\Vehicles\$COMPONENT"" "
    start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow -Wait

    # remove the masfile because we have everything extracted
    remove-item $CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE
    }

 # if there is no checksums.txt create an empty one
 if (-not (Test-Path $CURRENTLOCATION\Vehicles\$COMPONENT\checksums.txt))
 {
  New-Item -ItemType File -Path $CURRENTLOCATION\Vehicles\$COMPONENT\checksums.txt
 }

 # get all files which are in $COMPONENT in order to build checksum
 $SKINFILES=(Get-ChildItem -Path "$CURRENTLOCATION\Vehicles\$COMPONENT" -Exclude checksums.txt).Name

 # are there any filenames in checksums.txt which are not in $COMPONENT?
 #
 # read checksums from checksums.txt
 $CHECKSUMS=(Get-Content "$CURRENTLOCATION\Vehicles\$COMPONENT\checksums.txt")
 
 # compare each line with entries in $SKINFILES
  forEach ($CHECKSUM in $CHECKSUMS) 
   { $FILENAME=(($CHECKSUM) -split('=') | select-object -First 1) 
     if (-not($SKINFILES -contains $FILENAME))
      { 
       write-host "Entry of checksums.txt not found in list of skinfiles - removing from checksums.txt." 

       # read checksums.txt and write back entries which do not match $FILENAME
       Set-Content -Path "$CURRENTLOCATION\Vehicles\$COMPONENT\checksums.txt" -Value (get-content -Path "$CURRENTLOCATION\Vehicles\$COMPONENT\checksums.txt" | Select-String -Pattern $FILENAME -NotMatch)

      # set a marker that the components RFCMP needs to be generated new
      $UPDATERFCMP=1
      }
   }

 # check each file in SKINFILES
 forEach ($SKINFILE in $SKINFILES)
 {
     # generating checksum of the actual file
     $CHECKSUM=(Get-FileHash $CURRENTLOCATION\Vehicles\$COMPONENT\$SKINFILE).hash

     # get the previously saved checksum from checksums.txt (will be NULL if no entry is found)
     $SUM2COMPARE=((Get-Content "$CURRENTLOCATION\Vehicles\$COMPONENT\checksums.txt"|select-string -Pattern $SKINFILE+"=") -split("=") | select-object -Last 1)

    # if the checksums do not match
    if ($CHECKSUM -ne $SUM2COMPARE) 
     {
      write-host "Checksum for "$SKINFILE" does not match, update required."

      # replace the old checksum in checksums.txt with the new one
      if ( (Get-Content "$CURRENTLOCATION\Vehicles\$COMPONENT\checksums.txt"|select-string -Pattern $SKINFILE+":") )
      {
       $CHECKSUMFILE=(Get-Content "$CURRENTLOCATION\Vehicles\$COMPONENT\checksums.txt")
       $CHECKSUMFILE -replace "$SKINFILE=.*","$SKINFILE=$SUM2COMPARE" | Out-File $CURRENTLOCATION\Vehicles\$COMPONENT\checksums.txt
      } else
      {
       # this will add new checksum entries if the file did not exist before
       $SKINFILE+"="+$CHECKSUM | Out-File -Append $CURRENTLOCATION\Vehicles\$COMPONENT\checksums.txt
      }

      # set a marker that the components RFCMP needs to be generated new
      $UPDATERFCMP=1
     }
 }

# look for already existing RFCMPs
 $OLDRFCMPS=((Get-ChildItem $CURRENTLOCATION\Content -Name)|select-string -Pattern $COMPONENT)
 
# remove old RFCMPs ...
 if ($OLDRFCMPS){
  forEach($OLDRFCMP in $OLDRFCMPS)
  {
   write-host "Deleting previous version of "$COMPONENT" rfcmp in content folder."
   remove-item $CURRENTLOCATION\content\$OLDRFCMP
  }
 }

# if the components RFCMP is to be generated new
 if ($UPDATERFCMP -eq 1)
 {
    write-host "Packing masfile for RFCMP "$COMPONENT

    # get rid of the long lines
    $CMPPATH="$CURRENTLOCATION\Vehicles\$COMPONENT"

    # as this is the name of the mas file if we build it ...
    $MASFILE="$RFCMPPREFIX-skins.mas"

    # build argument list for modmgr
    $ARGUMENTS=" -m""$CMPPATH\$MASFILE"" ""$CMPPATH\*.json"" ""$CMPPATH\*.dds"" ""$CMPPATH\*.veh"" ""$CMPPATH\*.png"" ""$CMPPATH\*.ini"""
    
    # run modmgr to build mas file
    start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow  -Wait

    write-host "Listing all files in "$MASFILE" for logging."

    # arguments to list all files in masfile
    $ARGUMENTS=" -l""$CMPPATH\$MASFILE"" ""$CURRENTLOCATION\Log\content-generated-masfile-$COMPONENT-$CURRENTVERSION.txt"" "

    # run modmgr
    start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow  -Wait
    
   write-host "Building RFCMP for "$COMPONENT

 # change vehicle.dat file to add mas file
 $CMPINFO=($CMPINFO -replace "^MASFile=.*","MASFile=$CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE")

 #
 write-host "Building RFCMP for "$COMPONENT" with version "$CURRENTVERSION

 # write the rfcmp definition
 $CMPINFO | Out-File "$CURRENTLOCATION\$COMPONENT-$CURRENTVERSION.dat" -Encoding ASCII

 # build argument list for modmgr
 $ARGUMENTS=" -b""$CURRENTLOCATION\$COMPONENT-$CURRENTVERSION.dat"" 0 "
    
 # run modmgr to build rfcmp
 start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow  -Wait

 # delete the vehicle / rfcmp dat file
 #remove-item $CURRENTLOCATION\$COMPONENT.dat

 # move the definition file to log folder
 move-item $CURRENTLOCATION\$COMPONENT-$CURRENTVERSION.dat Log\ -Force

 remove-item $CURRENTLOCATION\Vehicles\$COMPONENT\$MASFILE
 }

 # set the marker to 0 as we have build a new RFCMP
 $UPDATERFCMP=0
 }

# prepare Steam Workshop Upload
#
# if there is the template ... then ...
 if ( (Test-Path "$CURRENTLOCATION\metadata.tpl" -PathType Leaf) -and (!(Test-Path "$CURRENTLOCATION\metadata.tpl" -PathType Leaf)) ) 
{
 write-host "Using metadata template for metadata.vdf generation."

 # read in metadata template
 $METADATAINFO=(get-content $CURRENTLOCATION\metadata.tpl)

 # change the metadata template
 $METADATAINFO=($METADATAINFO -replace """contentfolder"".*","""contentfolder"" ""$CURRENTLOCATION\Content""")
 $METADATAINFO=($METADATAINFO -replace """changenote"".*","""changenote"" ""$CURRENTVERSION""")
 $METADATAINFO=($METADATAINFO -replace """description"".*","""description"" ""$METADATADESCR""")
 $METADATAINFO=($METADATAINFO -replace """title"".*","""title"" ""$METADATATITLE""")
 $METADATAINFO=($METADATAINFO -replace """previewfile"".*","""previewfile"" ""$CURRENTLOCATION\$METADATAPREVFILE""")

 # write back template
 $METADATAINFO | Out-File "$CURRENTLOCATION\metadata.vdf" -Encoding ASCII
 remove-item $CURRENTLOCATION\metadata.tpl
}

if ( Test-Path "$CURRENTLOCATION\metadata.vdf" -PathType Leaf )
{
 # check if steamcmd is already installed
 if (-not(Test-path "$CURRENTLOCATION\SteamCMD\steamcmd.exe" -PathType leaf))
 {
  write-host "SteamCMD not found - downloading and installing."

  # check for folder and create it if not existing
  if (-not(Test-Path "$CURRENTLOCATION\SteamCMD" -PathType Directory)) { mkdir $CURRENTLOCATION\SteamCMD }

  # download SteamCMD and unpack it
  start-process -FilePath powershell -ArgumentList "Invoke-RestMethod -Uri https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip -OutFile $CURRENTLOCATION\steamcmd.zip" -NoNewWindow -Wait
  start-process -FilePath powershell -ArgumentList "Expand-Archive -Force $CURRENTLOCATION\steamcmd.zip -DestinationPath $CURRENTLOCATION\SteamCMD" -NoNewWindow -Wait
  
  # run it once in order to configure it and check for Steam Guard
  start-process "$CURRENTLOCATION\SteamCMD\steamcmd.exe" -ArgumentList " +quit" -NoNewWindow -Wait

  # remove the downloaded archive
  remove-item $CURRENTLOCATION\steamcmd.zip
 }

 # call Steamcmd and upload the stuff
 if ( ($STEAMUPLOAD -eq "true") -and ($STEAMUSER -ne "changeme") -and ($STEAMPASSWORD -ne "changeme") )
 {
     write-host "Uploading files to Steam workshop."

     # building arguments for SteamCMD call ... remember to register the system with Steam guard code if configured (2FA)
     $ARGUMENTS=" +login ""$STEAMUSER"" ""$STEAMPASSWORD"" +workshop_build_item $CURRENTLOCATION\metadata.vdf +quit"

     # would we avoid PHP timeout if -Wait is being removed?
     start-process -FilePath "$CURRENTLOCATION\SteamCMD\SteamCMD.exe" -ArgumentList $ARGUMENTS # -NoNewWindow -Wait
 }
}
else 
{ 
 write-host "metadata.vdf missing for Steam workshop upload. Not uploading."
} 
