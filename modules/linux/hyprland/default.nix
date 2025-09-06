{
  pkgs,
  lib,
  config,
  ...
}:

let
  monitorType = "4k";
in
{
  wayland = {
    windowManager.hyprland = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.hyprland;
      settings = lib.mkMerge [
        (import ./config/env.nix)
        (import ./config/monitor.nix { inherit monitorType; })
        (import ./config/appearance.nix)
        (import ./config/input.nix)
        (import ./config/keybindings.nix)
        (import ./config/windowrules.nix)
      ];
    };
  };

  home.sessionVariables = {
    GDK_SCALE = if monitorType == "4k" then "2" else "1";
  };
}
