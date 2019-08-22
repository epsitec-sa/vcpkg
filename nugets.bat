@echo off
REM This script should be written in bash instead of batch...

REM When incrementing the versions, ensure to change the versions
REM in the port CONTROL files too.
set OPENSSL_WINDOWS_VERSION=1.0.2.4
set ZLIB_VERSION=1.2.11.8
set GRPC_PKG_VERSION=4
set GRPC_VERSION=1.22.0.%GRPC_PKG_VERSION%

REM remove previous builds
rd /s /q installed

REM build the projects
vcpkg install openssl-windows:x86-windows-static openssl-windows:x64-windows-static
vcpkg install zlib:x86-windows-static zlib:x64-windows-static
vcpkg install grpc:x86-windows-static grpc:x64-windows-static

REM export all projects as nuget packages
vcpkg export openssl-windows:x86-windows-static openssl-windows:x64-windows-static --nuget --nuget-id=epsitec-openssl --nuget-version=%OPENSSL_WINDOWS_VERSION%
vcpkg export zlib:x86-windows-static zlib:x64-windows-static --nuget --nuget-id=epsitec-zlib --nuget-version=%ZLIB_VERSION%
vcpkg export grpc:x86-windows-static grpc:x64-windows-static --nuget --nuget-id=epsitec-grpc --nuget-version=%GRPC_VERSION%

echo Press any key to continue with nuget publishing and push...
echo Please, check for errors first
pause

REM publish zlib and openssl-windows packages on nuget.org repository
nuget push epsitec-openssl.%OPENSSL_WINDOWS_VERSION%.nupkg -Source https://api.nuget.org/v3/index.json
nuget push epsitec-zlib.%ZLIB_VERSION%.nupkg -Source https://api.nuget.org/v3/index.json

REM copy and commit grpc package to the zou.chicken repository (> 250 MB)
set /a GRPC_OLD_PKG_VERSION=%GRPC_PKG_VERSION%-1
copy epsitec-grpc.%GRPC_VERSION%.nupkg ..\..\zou.chicken
git -C ../../zou.chicken clean -xdf
git -C ../../zou.chicken checkout master -f
git -C ../../zou.chicken pull -f
git -C ../../zou.chicken add epsitec-grpc.%GRPC_VERSION%.nupkg
git -C ../../zou.chicken rm -f epsitec-grpc.1.22.0.%GRPC_OLD_PKG_VERSION%.nupkg
git -C ../../zou.chicken commit -m "Upgrade epsitec-grpc package to v%GRPC_VERSION%"
git -C ../../zou.chicken push

REM nuget setApiKey 
REM nuget push epsitec-grpc.1.22.0.1.nupkg -Source https://api.nuget.org/v3/index.json
REM nuget push epsitec-grpc.1.22.0.1.nupkg -Source http://nuget.epsitec.ch/ Spq35aUw.330_pqEgM