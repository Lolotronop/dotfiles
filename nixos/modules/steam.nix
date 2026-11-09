{ inputs, self, ... }: {
  flake.nixosModules.steam = { pkgs, ... }: {
    programs.steam.enable = true;
  };
}
