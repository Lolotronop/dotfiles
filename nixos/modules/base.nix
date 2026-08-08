{inputs, self, ...}: {
  flake.nixosModules.base = {pkgs,...}: {
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

      lazygit
      delta

      btop
      htop

      pi-coding-agent

      # TOOD: seriously consider if I need it
      # I have wezterm and maybe ghostty for this?
      tmux
    ];

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
