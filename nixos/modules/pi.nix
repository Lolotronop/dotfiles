{ inputs, self, ... }: {
  flake.nixosModules.pi =
    { pkgs, lib, ... }:
    let
      piCodexHelpers = pkgs.stdenv.mkDerivation rec {
        pname = "pi-codex-helpers";
        version = "3.0.14";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/@howaboua/pi-codex-conversion/-/pi-codex-conversion-${version}.tgz";
          hash = "sha256-MPS9ULdPClmnXDnT0JsMiZj7Z4fiGD1pL6Bpg7BnF6w=";
        };

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [
          pkgs.openssl_3
          pkgs.alsa-lib
          pkgs.stdenv.cc.cc.lib
        ];

        unpackPhase = "tar -xzf $src";
        installPhase = ''
          mkdir -p $out/bin
          install -Dm755 package/src/tools/exec/bin/linux-x64/exec_bridge $out/bin/exec_bridge
          install -Dm755 package/src/tools/apply-patch/bin/linux-x64/apply_patch $out/bin/apply_patch
          install -Dm755 package/src/tools/view-image/bin/linux-x64/view_image $out/bin/view_image
          install -Dm755 package/src/tools/web-run/bin/linux-x64/web_run $out/bin/web_run
          install -Dm755 package/src/tools/imagegen/bin/linux-x64/imagegen $out/bin/imagegen
          install -Dm755 package/src/voice/bin/linux-x64/pi-codex-voice $out/bin/pi-codex-voice
        '';
      };
      helperNames = [
        "exec_bridge"
        "apply_patch"
        "view_image"
        "web_run"
        "imagegen"
        "pi-codex-voice"
      ];
      helpersDir = "/home/lolotronop/.pi/codex-helpers/bin";
    in
    {
      environment.systemPackages = [ pkgs.pi-coding-agent ];

      # This directory is not npm-managed, so Pi upgrades do not replace it.
      system.activationScripts.piCodexHelpers = lib.stringAfter [ "users" ] ''
        install -d -m 0755 -o lolotronop -g users "${helpersDir}"
        ${lib.concatMapStringsSep "\n        " (helper: ''
          ln -sfn "${piCodexHelpers}/bin/${helper}" "${helpersDir}/${helper}"
        '') helperNames}
        chown -h lolotronop:users "${helpersDir}"/*
      '';
    };
}
