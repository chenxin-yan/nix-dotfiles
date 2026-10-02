{
  features.vesktop.homeManager = {
    programs.vesktop = {
      enable = true;

      settings = {
        arRPC = true;
        customTitleBar = true;
        disableMinSize = true;
        minimizeToTray = true;
        tray = true;
        splashTheming = true;
        staticTitle = true;
        hardwareAcceleration = true;
        discordBranch = "stable";
      };

      vencord = {
        settings = {
          autoUpdate = false;
          autoUpdateNotification = false;
          useQuickCss = true;
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
        useSystem = true;
      };
    };
  };
}
