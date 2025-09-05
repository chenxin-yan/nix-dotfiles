{
  pkgs,
  lib,
  config,
  ...
}:

{
  wayland = {
    windowManager.hyprland = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.hyprland;
      settings = {
        # For 4K Monitors (3840x2160)
        monitor = ",preferred,auto,2";

        # For 1440p Monitors (2560x1440)
        # monitor = ",preferred,auto,1";

        # For 1080p Monitors (1920x1080)
        # monitor = ",preferred,auto,1";
      };
    };
  };

  home.sessionVariables = {
    # For 4K Monitors
    GDK_SCALE = "2";

    # For 1440p or 1080p Monitors
    # GDK_SCALE = "1";
  };
}
