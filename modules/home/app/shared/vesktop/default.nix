{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    app.shared.vesktop.enable = lib.mkEnableOption "enables Vesktop (Discord client)";
  };

  config = lib.mkIf config.app.shared.vesktop.enable {
    programs.vesktop = {
      enable = true;

      settings = {
        arRPC = true;
        checkUpdates = false;
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
          notifyAboutUpdates = false;
          useQuickCss = true;
          disableMinSize = true;
          plugins = {
            MessageLogger = {
              enabled = true;
              ignoreSelf = true;
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
