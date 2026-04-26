# Proxy helpers for Git Bash / WSL / Linux / macOS
# Source this file from ~/.bashrc:   source ~/proxyrc.sh

proxy-on() {
    local port="$1"
    if [ -z "$port" ]; then
        read -r -p "Proxy port (default 2081): " port
        port="${port:-2081}"
    fi

    local url="http://127.0.0.1:${port}"
    export HTTP_PROXY="$url"
    export HTTPS_PROXY="$url"
    export http_proxy="$url"
    export https_proxy="$url"
    export ALL_PROXY="$url"
    export all_proxy="$url"
    export NO_PROXY="localhost,127.0.0.1,::1"
    export no_proxy="$NO_PROXY"

    echo "Proxy ON  -> 127.0.0.1:${port}"
}

proxy-off() {
    unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy \
          ALL_PROXY all_proxy NO_PROXY no_proxy
    echo "Proxy OFF"
}

proxy-status() {
    if [ -n "$HTTP_PROXY" ]; then
        echo "Proxy: $HTTP_PROXY"
    else
        echo "Proxy: OFF"
    fi
}
