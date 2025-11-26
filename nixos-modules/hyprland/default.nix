{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    nixos.hyprland.enable = lib.mkEnableOption "enables Hyprland wayland compositor (system-level)";
  };

  config = lib.mkIf config.nixos.hyprland.enable {
    # Hyprland with UWSM integration
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # XDG Desktop Portal configuration
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}
