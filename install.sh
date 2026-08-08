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

get_firefox_default_profile_path() {
    local profiles_ini=""

    if [[ -f "${HOME}/.mozilla/firefox/profiles.ini" ]]; then
        profiles_ini="${HOME}/.mozilla/firefox/profiles.ini"
    elif [[ -f "${HOME}/.config/mozilla/firefox/profiles.ini" ]]; then
        profiles_ini="${HOME}/.config/mozilla/firefox/profiles.ini"
    else
        return 1
    fi

    local current_section=""
    local install_default=""
    local fallback_path=""
    local fallback_relative=""
    local profile_default=""
    local profile_path=""
    local profile_relative=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Strip CR in case the file has CRLF line endings.
        line="${line%$'\r'}"

        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            # Before moving to the next section, check whether the
            # previous Profile* section was marked as default.
            if [[ "$current_section" == Profile* &&
                  "$profile_default" == "1" &&
                  -z "$fallback_path" ]]; then
                fallback_path="$profile_path"
                fallback_relative="$profile_relative"
            fi

            current_section="${BASH_REMATCH[1]}"

            profile_default=""
            profile_path=""
            profile_relative=""
            continue
        fi

        [[ "$line" == *=* ]] || continue

        local key="${line%%=*}"
        local value="${line#*=}"

        if [[ "$current_section" == Install* ]]; then
            if [[ "$key" == "Default" && -z "$install_default" ]]; then
                install_default="$value"
            fi
        elif [[ "$current_section" == Profile* ]]; then
            case "$key" in
                Default)
                    profile_default="$value"
                    ;;
                Path)
                    profile_path="$value"
                    ;;
                IsRelative)
                    profile_relative="$value"
                    ;;
            esac
        fi
    done < "$profiles_ini"

    # Handle the final section.
    if [[ "$current_section" == Profile* &&
          "$profile_default" == "1" &&
          -z "$fallback_path" ]]; then
        fallback_path="$profile_path"
        fallback_relative="$profile_relative"
    fi

    local chosen_path=""

    if [[ -n "$install_default" ]]; then
        chosen_path="$install_default"

        # Install*.Default is normally relative to the Firefox profile dir.
        if [[ "$chosen_path" != /* ]]; then
            chosen_path="$(dirname "$profiles_ini")/$chosen_path"
        fi
    elif [[ -n "$fallback_path" ]]; then
        chosen_path="$fallback_path"

        if [[ "$fallback_relative" == "1" ]]; then
            chosen_path="$(dirname "$profiles_ini")/$chosen_path"
        fi
    else
        return 1
    fi

    if [[ -d "$chosen_path" ]]; then
        realpath "$chosen_path"
        return 0
    fi

    return 1
}

if firefox_profile_path="$(get_firefox_default_profile_path)"; then
    echo "Firefox profile found: $firefox_profile_path"
    link_item "windows/firefox" "$firefox_profile_path/chrome"
else
    echo "Firefox profile not found."
fi

link_item "nixos" "~/.config/nixos"
link_item "nix" "~/.config/nix"
link_item "fish" "~/.config/fish"
link_item "lazygit" "~/.config/lazygit"
link_item "tmux" "~/.config/tmux"
link_item "starship/starship.toml" "~/.config/starship.toml"

link_item "ghostty" "~/.config/ghostty"
link_item "windows/mpv/scripts/prefixtracks.lua" "~/.config/mpv/scripts/prefixtracks.lua"
