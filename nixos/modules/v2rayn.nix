{inputs, self, ...}: {
  flake.nixosModules.v2rayn = {pkgs,...}: {
    environment.systemPackages = with pkgs; [
      v2rayn
      sing-box
      xray
    ];

    systemd.tmpfiles.rules = [
      "d /home/lolotronop/.local/share/v2rayN/bin/sing_box 0755 lolotronop users -"
      "d /home/lolotronop/.local/share/v2rayN/bin/xray 0755 lolotronop users -"

      "L+ /home/lolotronop/.local/share/v2rayN/bin/sing_box/sing-box - - - - ${pkgs.sing-box}/bin/sing-box"
      "L+ /home/lolotronop/.local/share/v2rayN/bin/xray/xray - - - - ${pkgs.xray}/bin/xray"
    ];
  };
}
