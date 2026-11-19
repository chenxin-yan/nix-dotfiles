{
  features.vesktop.homeManager = {
    programs.vesktop = {
      enable = true;
      # Vesktop rewrites settings.json at runtime, replacing the HM symlink.
      mutableSettings = true;

      settings = {
        disableMinSize = true;
        staticTitle = true;
      };

      vencord = {
        settings = {
          autoUpdateNotification = false;
          disableMinSize = true;
          plugins = {
            MessageLogger = {
              enabled = true;
              ignoreSelf = true;
              ignoreBots = true;
            };
            AlwaysTrust = {
              enabled = true;
            };
            AppleMusicRichPresence = {
              enabled = true;
            };
          };
        };
        # Discord updates independently of Nix; keep Vencord's compatibility fixes current.
        useSystem = false;
      };
    };
  };
}
