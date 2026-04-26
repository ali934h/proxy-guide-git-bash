@echo off
if defined HTTP_PROXY (
    echo Proxy: %HTTP_PROXY%
) else (
    echo Proxy: OFF
)
