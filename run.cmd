start "IIS" "C:\Program Files (x86)\IIS Express\iisexpress.exe" /path:"%CD%\src\witness.specs" /port:1234
tools\phantomjs\phantomjs.exe phantom.js %1
taskkill /im iisexpress.exe
