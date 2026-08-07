{inputs, self, ...}: {
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.default

      self.nixosModules.base

      self.nixosModules.hostWsl
    ];
  };

  flake.nixosModules.hostWsl = {pkgs, ...}: {
    environment.variables.NIXOS_HOST = "wsl";
    wsl.enable = true;
    wsl.defaultUser = "lolotronop";
    security.sudo.wheelNeedsPassword = true;
    system.stateVersion = "26.05";
  };
}
