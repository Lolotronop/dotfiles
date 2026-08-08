#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

link_item() {
    local src_rel="$1"
    local dst="$2"

    local src="$SCRIPT_DIR/$src_rel"

    # Expand ~
    dst="${dst/#\~/$HOME}"

    # Source must exist
    if [[ ! -e "$src" ]]; then
        echo "Source does not exist: $src"
        return 1
    fi

    # If destination is an existing directory and source is a file,
    # place the link inside it using the source filename.
    if [[ -f "$src" && -d "$dst" ]]; then
        dst="$dst/$(basename "$src")"
    fi

    # Skip if correct symlink already exists
    if [[ -L "$dst" ]]; then
        echo "Skipping existing symlink: $dst"
        return 0
    fi

    # Backup existing file/dir
    if [[ -e "$dst" ]]; then
        local backup="${dst}.bak"

        # Avoid overwriting an existing backup
        while [[ -e "$backup" ]]; do
            backup="${backup}.bak"
        done

        mv "$dst" "$backup"
        echo "Backed up:"
        echo "  $dst"
        echo "-> $backup"
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$dst")"

    ln -s "$src" "$dst"

    echo "Linked:"
    echo "  $src"
    echo "-> $dst"
}

link_item "nixos" "~/.config/nixos"
link_item "nix" "~/.config/nix"
link_item "fish" "~/.config/fish"
link_item "lazygit" "~/.config/lazygit"
link_item "tmux" "~/.config/tmux"
link_item "starship/starship.toml" "~/.config/starship.toml"

link_item "ghostty" "~/.config/ghostty"
