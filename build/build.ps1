if (!(test-path output\scripts)) { mkdir output\scripts }
if (!(test-path output\styles)) { mkdir output\styles }

tools\ajaxmin.exe -JS -clobber -xml ajaxmin.xml

copy "..\src\lib\*.js"     "output\scripts\" -force
copy "..\src\styles\*.css" "output\styles\"  -force
copy "..\src\witness.htm"  "output"          -force

# Rewrite the script src attributes to reference the built file locations
$html = Get-Content "output\witness.htm"
$html -replace "../build/witness-raw.js", "scripts/witness.js" `
	  -replace "src=""lib/", "src=""scripts/" `
	  | Set-Content "output\witness.htm"