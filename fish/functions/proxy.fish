function proxy
    set -lx http_proxy http://127.0.0.1:10808
    set -lx https_proxy http://127.0.0.1:10808

    set -lx HTTP_PROXY http://127.0.0.1:10808
    set -lx HTTPS_PROXY http://127.0.0.1:10808

    set -lx all_proxy http://127.0.0.1:10808
    set -lx ALL_PROXY http://127.0.0.1:10808

    command $argv
end
