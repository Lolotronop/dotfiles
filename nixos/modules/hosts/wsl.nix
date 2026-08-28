{ inputs, self, ... }: {
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.default

      self.nixosModules.base
      self.nixosModules.pi
      self.nixosModules.docker
      self.nixosModules.syncthing

      self.nixosModules.hostWsl
    ];
  };

  flake.nixosModules.hostWsl =
    { pkgs, lib, ... }:
    {
      environment.variables.NIXOS_HOST = "wsl";
      networking.hostName = "lolo-wsl";
      wsl.enable = true;
      wsl.defaultUser = "lolotronop";
      security.sudo.wheelNeedsPassword = true;
      system.stateVersion = "26.05";

      # Keep the WSL instance separate from Syncthing running on Windows.
      services.syncthing = {
        openDefaultPorts = lib.mkForce false;
        guiAddress = "127.0.0.1:8385";

        settings.options = {
          listenAddresses = [
            "tcp://0.0.0.0:22001"
            "quic://0.0.0.0:22001"
            "dynamic+https://relays.syncthing.net/endpoint"
          ];
          localAnnouncePort = 21028;
          localAnnounceMCAddr = "[ff12::8384]:21028";
        };
      };

      networking.firewall = {
        allowedTCPPorts = [ 22001 ];
        allowedUDPPorts = [
          21028
          22001
        ];
      };

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
