{ inputs, self, ... }: {
  flake.nixosConfigurations.vostro = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.nixosModules.base
      self.nixosModules.pi
      self.nixosModules.power
      self.nixosModules.desktop
      self.nixosModules.hyprland
      self.nixosModules.bluetooth

      self.nixosModules.docker
      self.nixosModules.syncthing

      self.nixosModules.v2rayn
      self.nixosModules.zapret

      self.nixosModules.hostVostro
    ];
  };

  flake.nixosModules.hostVostro = { pkgs, lib, ... }: {
    environment.variables.NIXOS_HOST = "vostro";
    networking.hostName = "lolo-vostro";
    services.displayManager.defaultSession = lib.mkForce "plasma";

    # fix for backlight wrapping around after 65470
    # disables the hardware-privided curve for backlight
    boot.kernelParams = [ "amdgpu.dcdebugmask=0x40000" ];

    system.stateVersion = "26.05";
  };
}
