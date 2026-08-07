{inputs, self, ...}: {
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.default
      self.nixosModules.hostWsl
    ];
  };

  flake.nixosModules.hostWsl = {pkgs, ...}: {
    environment.variables.NIXOS_HOST = "wsl";
    wsl.enable = true;
    wsl.defaultUser = "lolotronop";
    security.sudo.wheelNeedsPassword = true;

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

    environment.systemPackages = with pkgs; [
      vim
      neovim
      git
      fd
      ripgrep
      tree-sitter
      gcc
      lazygit
      delta
      bat
      fish
      python3
      tmux # TOOD: seriously consider if I need it
    ];

    system.stateVersion = "26.05";
  };
}
