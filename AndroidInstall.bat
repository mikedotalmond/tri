@echo off

set APP_ID=mikedotalmond.experiment.tri
set APP_NAME=tri
set APP_PATH=air

echo.
echo Removing old version of the app
call adt -uninstallApp -platform android -appid %APP_ID%
echo.
echo Installing %APP_NAME%.apk...
call adt -installApp -platform android -package %APP_PATH%/%APP_NAME%.apk

echo.
echo Done