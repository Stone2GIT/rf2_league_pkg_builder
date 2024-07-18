#
# simple script to install nginx and php on windows

# Stone, 07/2024 info@simracingjustfair.org
#

# get current location path name
$CURRENTLOCATION=((Get-Location).Path)

# download NGINX and PHP and install it
write-host "Downloading NGINX"
start-process -FilePath powershell -ArgumentList "Invoke-RestMethod -Uri https://nginx.org/download/nginx-1.27.0.zip -OutFile $CURRENTLOCATION\nginx.zip" -NoNewWindow -Wait

write-host "Downloading PHP"
start-process -FilePath powershell -ArgumentList "Invoke-RestMethod -Uri https://windows.php.net/downloads/releases/php-8.3.9-Win32-vs16-x64.zip -OutFile $CURRENTLOCATION\php.zip" -NoNewWindow -Wait

# unpacking
write-host "Unpacking ..."
start-process -FilePath powershell -ArgumentList "Expand-Archive -Force $CURRENTLOCATION\nginx.zip -DestinationPath $CURRENTLOCATION\" -NoNewWindow -Wait
 move $CURRENTLOCATION\nginx-1.27.0 $CURRENTLOCATION\nginx
start-process -FilePath powershell -ArgumentList "Expand-Archive -Force $CURRENTLOCATION\php.zip -DestinationPath $CURRENTLOCATION\php" -NoNewWindow -Wait

# removing archives
del *.zip

# configure nginx
$NGINX_INSTALLDIR="$CURRENTLOCATION\nginx"
$NGINX_INSTALLDIR=($NGINX_INSTALLDIR -replace "\\","/")

$NGINXCONFIG=(gc $CURRENTLOCATION\configfiles\nginx\conf\nginx.conf)
$NGINXCONFIG=($NGINXCONFIG -replace "NGINX_INSTALLDIR","$NGINX_INSTALLDIR")

$NGINXCONFIG | Out-File $CURRENTLOCATION\nginx\conf\nginx.conf

# copy php configuration file
copy $CURRENTLOCATION\configfiles\php\php.ini $CURRENTLOCATION\php\php.ini 
 