{inputs, self, ...}: {
  flake.nixosConfigurations.vostro = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.nixosModules.base
      self.nixosModules.desktop
      self.nixosModules.power

      self.nixosModules.docker

      self.nixosModules.v2rayn

      self.nixosModules.hostVostro
    ];
  };

  flake.nixosModules.hostVostro = {pkgs, ...}: {
    environment.variables.NIXOS_HOST = "vostro";
    networking.hostName = "lolo-vostro";

    system.stateVersion = "26.05";
  };
}
