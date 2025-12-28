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
          (import ./config/monitor.nix)
          (import ./config/appearance.nix)
          (import ./config/input.nix)
          (import ./config/keybindings.nix)
          (import ./config/windowrules.nix)
        ];
      };
    };

    home.sessionVariables = {
      # Toolkit backends
      GDK_BACKEND = "wayland,x11,*";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";

      # Cursor size
      XCURSOR_SIZE = "24";
    };

    programs.vicinae = {
      enable = true;
      systemd = {
        autoStart = true;
        enable = true;
      };
    };

    programs.hyprlock.enable = true;
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "hyprlock";
          }
          {
            timeout = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
      systemdTarget = "hyprland-session.target";
    };
  };
}
