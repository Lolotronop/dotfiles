{ inputs, self, ... }: {
  flake.nixosModules.desktop = { config, pkgs, ... }: {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    programs.firefox.enable = true;
    environment.systemPackages = with pkgs; [
      ghostty
      kdePackages.kate
      telegram-desktop
      discord
      easyeffects

      (mpv.override {
        scripts = with mpvScripts; [
          thumbfast
          uosc
        ];
      })
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      ioskeley-mono.semiCondensed-term
      ioskeley-mono.condensed-term
    ];

    boot = {
      loader = {
        systemd-boot = {
          enable = true;

          # systemd-boot's automatic Windows entry has no configurable sort
          # key. Replace it with an equivalent keyed entry so it sorts before
          # every NixOS generation (whose default sort key is "nixos").
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
        efi = {
          canTouchEfiVariables = true;
        };
      };

      kernelPackages = pkgs.linuxPackages_latest;
    };

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networking.networkmanager.enable = true;

    #services.xserver.enable = true; # don't need the X11 server I think

    services.xserver.xkb = {
      layout = "us,ru";
      variant = ",";
    };
    # Enable touchpad support (enabled default in most desktopManager).
    services.xserver.libinput.enable = true;

    services.printing.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      #jack.enable = true;
    };

    users.users."lolotronop" = {
      isNormalUser = true;
      description = "lolotronop";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      packages = with pkgs; [ ];
    };

    time.timeZone = "Europe/Moscow";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_IDENTIFICATION = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
  };
}
