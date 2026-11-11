{ ... }: {
  flake.nixosModules.raddebugger = { pkgs, lib, ... }: let
    raddebugger = pkgs.clangStdenv.mkDerivation {
      pname = "raddebugger";
      version = "0-unstable-2026-11-04";

      src = pkgs.fetchFromGitHub {
        owner = "EpicGames";
        repo = "raddebugger";
        rev = "5b0d5f67a46af5fffa52322e95a116dabf393103";
        hash = "sha256-fmFGAI2MCvvWAJ1GgmQ3rZOw5ocU+FzRpYSQeUH/z0o=";
      };

      nativeBuildInputs = [ pkgs.pkg-config pkgs.copyDesktopItems ];
      buildInputs = with pkgs; [
        freetype
        libX11
        libXext
        libXfixes
        libXrandr
        libGL
      ];

      dontConfigure = true;
      buildPhase = ''
        runHook preBuild
        bash build.sh raddbg release
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        install -Dm755 build/raddbg "$out/bin/raddbg"
        install -Dm644 data/logo.png "$out/share/icons/hicolor/256x256/apps/raddebugger.png"
        runHook postInstall
      '';

      desktopItems = [ (pkgs.makeDesktopItem {
        name = "raddebugger";
        desktopName = "RAD Debugger";
        comment = "Native graphical debugger";
        exec = "raddbg";
        icon = "raddebugger";
        categories = [ "Development" "Debugger" ];
      }) ];

      meta = {
        description = "Native, multi-process graphical debugger";
        homepage = "https://github.com/EpicGames/raddebugger";
        license = lib.licenses.mit;
        mainProgram = "raddbg";
        platforms = [ "x86_64-linux" ];
      };
    };
  in {
    environment.systemPackages = [ raddebugger ];
  };
}
