function pi --wraps pi
    begin
        # pi-codex-conversion falls back to /bin/bash for Fish; NixOS has none.
        set -lx SHELL (command -s bash)
        set -lx http_proxy http://127.0.0.1:10808
        set -lx https_proxy http://127.0.0.1:10808
        set -lx HTTP_PROXY http://127.0.0.1:10808
        set -lx HTTPS_PROXY http://127.0.0.1:10808
        command pi $argv
    end
end
