#!/usr/bin/env bash
# loads ssh keys in the current directory into ssh-agent

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

install -m 600 id_ed25519      "$HOME/.ssh/id_ed25519"
install -m 644 id_ed25519.pub  "$HOME/.ssh/id_ed25519.pub"

sudo chown -R "$USER":"$USER" "$HOME/.ssh"

if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
  eval "$(ssh-agent -s)"
fi

ssh-add "$HOME/.ssh/id_ed25519"

rm id_ed25519
rm id_ed25519.pub
