{ inputs, self, ... }: {
  flake.nixosModules.hyprland = { pkgs, ... }: {
    programs.hyprland.enable = true;

    environment.systemPackages = with pkgs; [
      kitty
      noctalia
      hyprpicker
      wl-clipboard
      hyprpolkitagent
      playerctl
      brightnessctl
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
