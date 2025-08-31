{ pkgs, ... }:

{

  xdg.configFile."sketchybar" = {
    source = ./config;
    recursive = true;
  };

  # Use the icon_map.sh from the package instead of custom one
  xdg.configFile."sketchybar/plugins/icon_map.sh" = {
    source = "${pkgs.sketchybar-app-font}/bin/icon_map.sh";
  };

  programs.sketchybar = {
    enable = true;
    service = {
      enable = true;
    };
  };
}
