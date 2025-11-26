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
            "$menu" = "vicinae toggle";
            "$terminal" = "ghostty";
          }
          (import ./config/env.nix)
          (import ./config/monitor.nix)
          (import ./config/appearance.nix)
          (import ./config/input.nix)
          (import ./config/keybindings.nix)
          (import ./config/windowrules.nix)
        ];
      };
    };

    home.sessionVariables = { };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };

    programs.vicinae = {
      enable = true;
      systemd = {
        autoStart = true;
        enable = true;
      };
    };

    programs.hyprlock.enable = true;
  };
}
