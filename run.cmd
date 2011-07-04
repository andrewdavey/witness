start "IIS" "C:\Program Files (x86)\IIS Express\iisexpress.exe" /path:"%CD%\src\%1" /port:1234
tools\phantomjs\phantomjs.exe --disk-cache=yes run-witness.coffee "http://localhost:1234" %2
taskkill /im iisexpress.exe
