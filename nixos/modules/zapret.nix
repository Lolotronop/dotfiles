{ inputs, ... }: {
  flake.nixosModules.zapret = { ... }: {
    imports = [
      inputs.zapret-discord-youtube.nixosModules.withTestTools
    ];

    services.zapret-discord-youtube = {
      enable = true;
      configName = "general(ALT)";
      gameFilter = "all";

      # available configs:
      # configName = "general";
      # configName = "general (ALT12)";
      # configName = "general (EXP)";
      # configName = "general (FAKE_TLS_AUTO)";
      # configName = "general (FAKE_TLS_AUTO_ALT)";
      # configName = "general (FAKE_TLS_AUTO_ALT2)";
      # configName = "general (FAKE_TLS_AUTO_ALT3)";
      # configName = "general (SIMPLE FAKE ALT)";
      # configName = "general (SIMPLE FAKE)";
      # configName = "general (SIMPLE_FAKE_ALT2)";
      # configName = "general(ALT)";
      # configName = "general(ALT10)";
      # configName = "general(ALT11)";
      # configName = "general(ALT2)";
      # configName = "general(ALT3)";
      # configName = "general(ALT4)";
      # configName = "general(ALT5)";
      # configName = "general(ALT6)";
      # configName = "general(ALT7)";
      # configName = "general(ALT8)";
      # configName = "general(ALT9)";
    };
  };
}
