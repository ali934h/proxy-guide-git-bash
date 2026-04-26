# Proxy helpers for PowerShell (Windows PowerShell 5.1 and PowerShell 7+)
# Dot-source this file from your $PROFILE:   . "$HOME\proxy.ps1"

function proxy-on {
    param([int]$Port)

    if (-not $Port) {
        $entered = Read-Host "Proxy port (default 2081)"
        if ([string]::IsNullOrWhiteSpace($entered)) {
            $Port = 2081
        } else {
            $Port = [int]$entered
        }
    }

    $url = "http://127.0.0.1:$Port"
    $env:HTTP_PROXY  = $url
    $env:HTTPS_PROXY = $url
    $env:ALL_PROXY   = $url
    $env:NO_PROXY    = "localhost,127.0.0.1,::1"

    Write-Host "Proxy ON  -> 127.0.0.1:$Port" -ForegroundColor Green
}

function proxy-off {
    Remove-Item Env:HTTP_PROXY  -ErrorAction SilentlyContinue
    Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue
    Remove-Item Env:ALL_PROXY   -ErrorAction SilentlyContinue
    Remove-Item Env:NO_PROXY    -ErrorAction SilentlyContinue

    Write-Host "Proxy OFF" -ForegroundColor Yellow
}

function proxy-status {
    if ($env:HTTP_PROXY) {
        Write-Host "Proxy: $($env:HTTP_PROXY)" -ForegroundColor Cyan
    } else {
        Write-Host "Proxy: OFF" -ForegroundColor Yellow
    }
}
