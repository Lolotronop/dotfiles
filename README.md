# dotfiles

You know. The ones with dots and stuff. I try to keep em small and minimal
Neovim configuration is in a separate repo - [https://github.com/Lolotronop/nvim-config](https://github.com/Lolotronop/nvim-config)

## Installation

**NixOS** - run the `install.sh` script and do a `sudo nixos-rebuild switch --flake ~/.config/nixos#HOST` with the right `HOST` name.
You can find then in `~/.config/nixos/modules/hosts`, filenames match the hostnames. Currently I have only wsl in there

**Windows** - go into `windows/` folder and run `install.ps1`. That's it. Caveat - FilePilot overrides it's config symlink on edit,
so you will have to manually update it in the repo for the sync to work. I'll try to nag Vjekoslav to fix it
