{ inputs, ... }: {
  flake.nixosModules.bluetooth = { ... }: {
    imports = [
      inputs.bluevein.nixosModules.default
    ];

    services.bluevein.enable = true;

    # services.blueman.enable = true;
    hardware.xpadneo.enable = true; # Enable the xpadneo driver for Xbox One wireless controllers
    hardware.bluetooth = {
      enable = true;
      # powerOnBoot = true;
      settings.General = {
        experimental = true;

        # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
        # for pairing bluetooth controller
        Privacy = "device";
        JustWorksRepairing = "always";
        Class = "0x000100";
        FastConnectable = true;
      };
    };
  };
}
