{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    app.linux.waybar.enable = lib.mkEnableOption "enables waybar";
  };

  config = lib.mkIf config.app.linux.waybar.enable {
    catppuccin.waybar.enable = false;

    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };
  };
}
