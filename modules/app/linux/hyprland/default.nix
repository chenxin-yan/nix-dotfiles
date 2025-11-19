{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    app.linux.hyprland.enable = lib.mkEnableOption "enables hyprland wayland compositor";
  };

  config = lib.mkIf config.app.linux.hyprland.enable {
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
  };
}
