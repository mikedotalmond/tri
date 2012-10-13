@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

set AIR_TARGET=
set AIR_TARGET_TYPE=apk
set OPTIONS=-target apk
call bat\Packager.bat

pause