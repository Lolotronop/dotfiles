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
          "laptop-win".id = "R2OHSGF-AX2SQUI-DATFIIH-D3E3S62-5KRBQQP-QBIER5G-4SYUMRB-5W5AEQK";
        };

        folders = {
          maga = {
            path = "/home/lolotronop/maga";
            devices = [
              "laptop-win"
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
