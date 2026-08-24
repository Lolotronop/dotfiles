{ inputs, self, ... }: {
  flake.nixosModules.base = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      git
      vim

      fish
      starship
      bat

      neovim
      fd
      ripgrep
      tree-sitter
      gcc
      nixd

      devenv
      direnv

      lazygit
      delta

      btop
      htop

      nodejs
      bun
      python3

      ffmpeg
      imagemagick
      yt-dlp

      # TOOD: seriously consider if I need it
      # I have wezterm and maybe ghostty for this?
      tmux
    ];

    environment.variables.DEVENV_SHELL_TYPE = "fish";

    programs.git = {
      enable = true;
      config = {
        user = {
          name = "Andrew Lolotronop";
          email = "lolotron300037200123@gmail.com";
        };
        core = {
          pager = "delta";
        };

        interactive = {
          diffFilter = "delta --color-only";
        };

        delta = {
          navigate = true;
          dark = true; # set to false or use light/auto-detect if you prefer
        };

        merge = {
          conflictStyle = "zdiff3";
        };

        init = {
          defaultBranch = "main";
        };
      };
    };

    services.journald = {
      extraConfig = ''
        SystemMaxUse=512M
      '';
    };

    nixpkgs.config.allowUnfree = true;
  };
}
