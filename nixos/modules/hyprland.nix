{inputs, self, ...}: {
  flake.nixosModules.hyprland = {pkgs,...}: {
    programs.hyprland.enable = true;

    environment.systemPackages = with pkgs; [
      kitty
      noctalia
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
