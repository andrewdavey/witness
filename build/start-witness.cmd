echo off
set port=1234
SET ExecPath=%ProgramFiles(x86)%
IF "%ExecPath%"=="" SET ExecPath=%ProgramFiles%

echo Starting Witness web server at http://localhost:%port%

"%ExecPath%\iis express\iisexpress.exe" "/path:%cd%\web" /port:%port%

echo on