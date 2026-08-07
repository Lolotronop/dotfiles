# dotfiles

You know. The ones with dots and stuff. I try to keep em small and minimal

Neovim configuration is in a separate repo - [https://github.com/Lolotronop/nvim-config](https://github.com/Lolotronop/nvim-config)

## Installation

### NixOS
```sh
./install.sh
sudo nixos-rebuild switch --flake ~/.config/nixos#HOST` # change HOST to one of in nixos/modules/hosts/
```

### Windows
```powershell
cd windows/
powershell.exe -File install.ps1
```

Caveat - FilePilot overrides it's config symlink on edit,
so you will have to manually update it in the repo for the sync to work.
I'll try to nag Vjekoslav to fix it
