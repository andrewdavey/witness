msbuild /p:Configuration=Release ..\src\Witness\Witness.csproj
copy /y ..\src\Witness\bin\Witness.dll Witness\lib\
nuget pack Witness\Witness.nuspec
