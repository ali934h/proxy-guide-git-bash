@echo off
rem Usage: proxy-on [port]
rem If no port is given, ask interactively (default 2081).

if not "%~1"=="" (
    set "port=%~1"
) else (
    set /p port=Proxy port (default 2081): 
)

if "%port%"=="" set "port=2081"

set "HTTP_PROXY=http://127.0.0.1:%port%"
set "HTTPS_PROXY=http://127.0.0.1:%port%"
set "ALL_PROXY=http://127.0.0.1:%port%"
set "NO_PROXY=localhost,127.0.0.1,::1"

echo Proxy ON  -^> 127.0.0.1:%port%
