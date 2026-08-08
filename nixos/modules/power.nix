{inputs, self, ...}: {
  flake.nixosModules.power = {pkgs,...}: {
    services.power-profiles-daemon.enable = true;
  };
}
