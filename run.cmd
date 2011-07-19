start "Witness Web Server" "C:\Program Files (x86)\IIS Express\iisexpress.exe" /path:"%CD%\src\witness" /port:8001
start "Application Web Server" "C:\Program Files (x86)\IIS Express\iisexpress.exe" /path:"%CD%\src\%1" /port:8002
tools\phantomjs\phantomjs.exe --disk-cache=yes run-witness.coffee "http://localhost:8001" "http://localhost:8002/" %2
taskkill /im iisexpress.exe
