{ ... }:
{
  flake.nixosModules.syncthing = { ... }: {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;

      user = "lolotronop";
      group = "users";
      dataDir = "/home/lolotronop";
      configDir = "/home/lolotronop/.config/syncthing";

      settings = {
        devices = {
          "lolo-spacewar".id = "IRVFK74-MP3BIE6-IHKW5TS-3XLGP23-YOLKXX7-NFGJVO3-USIMJAJ-TNE7HAM";
          "lolo-desktop-win".id = "42I5SNL-2KLAH6U-72CYZ4S-A7MSO5T-WXLWRPB-5T5OUGN-ITAOLRD-DF4E3QV";
          "lolo-ihor".id = "NR3E3UJ-VXPRHNU-7E5MQBQ-WIOB354-TWWSC77-2HHQTPV-6TO2WCA-EG63IAI";
        };

        folders = {
          maga = {
            path = "/home/lolotronop/maga";
            devices = [
              "lolo-spacewar"
              "lolo-desktop-win"
              "lolo-ihor"
            ];
            ignorePatterns = [
              # Common build, cache, and test output.
              ".cache"
              ".direnv"
              ".devenv"
              "build"
              "dist"
              "out"
              "bin"
              "coverage"
              "htmlcov"
              "tmp"

              # Python.
              "__pycache__"
              ".venv"
              "venv"
              ".tox"
              ".nox"
              ".pytest_cache"
              ".mypy_cache"
              ".ruff_cache"
              ".pytype"
              ".hypothesis"
              "*.egg-info"

              # JavaScript and TypeScript.
              "node_modules"
              ".npm"
              ".pnpm-store"
              "**/.yarn/cache"
              ".next"
              ".nuxt"
              ".svelte-kit"
              ".angular"
              ".parcel-cache"
              ".turbo"

              # Rust, Java, Kotlin, and JVM build tools.
              "target"
              ".gradle"

              # C, C++, and related build systems.
              "cmake-build-*"
              "CMakeFiles"
              "_deps"
              ".conan"
              ".xmake"
              "meson-logs"
              "meson-private"
              "packagecache"

              # Zig, Swift, Dart, Elixir, and Terraform.
              ".zig-cache"
              "zig-cache"
              "zig-out"
              ".build"
              "DerivedData"
              ".dart_tool"
              "_build"
              "deps"
              ".terraform"

              # Ruby and PHP dependencies.
              ".bundle"
              "vendor"

              # Editor and operating-system metadata.
              ".idea"
              ".DS_Store"
              "Thumbs.db"
            ];
          };
        };
      };
    };
  };
}
