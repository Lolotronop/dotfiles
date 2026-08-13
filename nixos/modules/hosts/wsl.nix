{ inputs, self, ... }: {
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.default

      self.nixosModules.base
      self.nixosModules.pi
      self.nixosModules.docker

      self.nixosModules.hostWsl
    ];
  };

  flake.nixosModules.hostWsl = { pkgs, ... }: {
    environment.variables.NIXOS_HOST = "wsl";
    wsl.enable = true;
    wsl.defaultUser = "lolotronop";
    security.sudo.wheelNeedsPassword = true;
    system.stateVersion = "26.05";

    # proxy requests to the Windows host instance of v2rayN
    # must enable allow from lan in v2rayN for this to work
    environment.systemPackages = [
      pkgs.socat
    ];

    systemd.services.windows-portproxy10808 = {
      description = "WSL/NixOS: forward localhost:10808 -> Windows $WIN_IP:10808 via socat";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 1;

        ExecStart = "${pkgs.bash}/bin/bash -lc 'read -r _ _ WIN_IP _ < <(ip route | grep -m1 default); exec ${pkgs.socat}/bin/socat TCP-LISTEN:10808,fork,reuseaddr TCP:\"$WIN_IP\":10808'";
      };
    };
  };
}
