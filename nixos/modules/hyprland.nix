{ inputs, self, ... }: {
  flake.nixosModules.hyprland = { pkgs, ... }: {
    programs.hyprland.enable = true;
    services.upower.enable = true; # for noctalia power display?

    # Set a consistent dark GTK preference and expose it through the settings portal.
    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
        };
      }
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "gtk";
    };

    # Qt6ct supplies a non-KDE Qt theme/palette for Qt6 applications.
    qt.enable = true;
    environment.sessionVariables.QT_QPA_PLATFORMTHEME = "qt6ct";

    environment.systemPackages = with pkgs; [
      kitty
      noctalia
      hyprpicker
      wl-clipboard
      hyprpolkitagent
      playerctl
      brightnessctl
      qt6Packages.qt6ct
      libsForQt5.qt5ct
      kdePackages.breeze
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      GTK_THEME = "Adwaita:dark";
      XCURSOR_THEME = "breeze_cursors";
      XCURSOR_SIZE = "24";
    };
  };
}
