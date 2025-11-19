{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    app.darwin.sketchybar.enable = lib.mkEnableOption "enables sketchybar status bar";
  };

  config = lib.mkIf config.app.darwin.sketchybar.enable {
    xdg.configFile."sketchybar" = {
      source = ./config;
      recursive = true;
    };

    # Use the icon_map.sh from the package instead of custom one
    xdg.configFile."sketchybar/plugins/icon_map.sh" = {
      source = "${pkgs.sketchybar-app-font}/bin/icon_map.sh";
    };
  };
}
