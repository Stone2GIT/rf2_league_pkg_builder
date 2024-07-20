taskkill /fi "imagename eq nginx.exe" /F
taskkill /fi "imagename eq php-cgi.exe" /F
cd nginx
start nginx
tasklist /fi "imagename eq nginx.exe"
cd php
php-cgi.exe -b 127.0.0.1:9123

