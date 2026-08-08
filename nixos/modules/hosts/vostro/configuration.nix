{inputs, self, ...}: {
  flake.nixosConfigurations.vostro = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.nixosModules.base
      self.nixosModules.power
      self.nixosModules.desktop
      self.nixosModules.hyprland

      self.nixosModules.docker

      self.nixosModules.v2rayn
      self.nixosModules.zapret

      self.nixosModules.hostVostro
    ];
  };

  flake.nixosModules.hostVostro = {pkgs, lib, ...}: {
    environment.variables.NIXOS_HOST = "vostro";
    networking.hostName = "lolo-vostro";
    services.displayManager.defaultSession = lib.mkForce "plasma";

    system.stateVersion = "26.05";
  };
}
