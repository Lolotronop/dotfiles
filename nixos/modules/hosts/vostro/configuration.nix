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

  flake.nixosModules.hostVostro = { config, pkgs, lib, ... }: {
    environment.variables.NIXOS_HOST = "vostro";
    networking.hostName = "lolo-vostro";
    services.displayManager.defaultSession = lib.mkForce "plasma";

    # systemd-boot's automatic Windows entry has no configurable sort key.
    # Replace it with an equivalent keyed entry so it sorts before every NixOS
    # generation (whose default sort key is "nixos").
    boot.loader.systemd-boot = {
      extraEntries."windows-11.conf" = ''
        title Windows 11
        sort-key a_windows
        efi /EFI/Microsoft/Boot/bootmgfw.efi
      '';
      extraInstallCommands = ''
        loader_conf=${config.boot.loader.efi.efiSysMountPoint}/loader/loader.conf
        ${pkgs.gnused}/bin/sed -i \
          -e '/^preferred /d' \
          -e 's/^default .*/default windows-11.conf/' \
          "$loader_conf"
        echo 'auto-entries no' >> "$loader_conf"
      '';
    };

    # fix for backlight wrapping around after 65470
    # disables the hardware-privided curve for backlight
    boot.kernelParams = [ "amdgpu.dcdebugmask=0x40000" ];

    system.stateVersion = "26.05";
  };
}
