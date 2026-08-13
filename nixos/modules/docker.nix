{ inputs, self, ... }: {
  flake.nixosModules.docker = { pkgs, ... }: {
    users.users.lolotronop.extraGroups = [ "docker" ];

    virtualisation.docker = {
      enable = true;

      daemon = {
        settings = {
          "live-restore" = true;
        };
      };

      autoPrune = {
        enable = true;
        dates = "weekly";
        randomizedDelaySec = "15min";

        flags = [
          "--filter=until=720h"
          "--all"
        ];
        allVolumes.enable = false;
      };
    };
  };
}
