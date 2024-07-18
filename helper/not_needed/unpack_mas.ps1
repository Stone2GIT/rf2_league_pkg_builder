#
. ../variables.ps1

$DIRECTORIES=((gci -Exclude unpack_mas.ps1).Name)

forEach ($DIRECTORY in $DIRECTORIES)
{

cd  $DIRECTORY

$CURRENTLOCATION=((Get-Location).Path)
$MASFILE=(((gci -File).Name) |select-string -Pattern ".mas")

$ARGUMENTS=" *.* -x""$CURRENTLOCATION\$MASFILE"" "
$ARGUMENTS
    
start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -NoNewWindow -Wait
del $MASFILE
cd c:\nginx\html\vehicles

}