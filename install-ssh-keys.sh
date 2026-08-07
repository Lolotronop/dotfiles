# Run from your home directory (or change ~ below)
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Copy (or install) keys from current directory to ~/.ssh
install -m 600 id_ed25519      "$HOME/.ssh/id_ed25519"
install -m 644 id_ed25519.pub  "$HOME/.ssh/id_ed25519.pub"

# Ensure ownership is correct (usually already fine)
sudo chown -R "$USER":"$USER" "$HOME/.ssh"

# Start ssh-agent and add the private key
# (Only starts/loads agent if needed)
if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
  eval "$(ssh-agent -s)"
fi

ssh-add "$HOME/.ssh/id_ed25519"

rm id_ed25519
rm id_ed25519.pub
