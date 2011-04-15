start "IIS" "C:\Program Files (x86)\IIS Express\iisexpress.exe" /path:"C:\Users\Andrew Davey\projects\opensource\witness" /port:1234
tools\phantomjs.exe phantom.js %1
taskkill /im iisexpress.exe