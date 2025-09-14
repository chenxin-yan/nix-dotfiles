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
      settings = lib.mkMerge [
        {
          "$menu" = "rofi -show drun";
          "$terminal" = "ghostty";
        }
        (import ./config/env.nix)
        (import ./config/monitor.nix)
        (import ./config/appearance.nix)
        (import ./config/input.nix)
        (import ./config/keybindings.nix)
        (import ./config/windowrules.nix)
        {
          "exec-once" = "waybar";
        }
      ];
    };
  };

  home.sessionVariables = {
    GDK_SCALE = "2";
  };

  programs.rofi = {
    enable = true;
  };
}
