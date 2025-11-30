{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    app.linux.waybar.enable = lib.mkEnableOption "enables waybar with mechabar theme";
  };

  config = lib.mkIf config.app.linux.waybar.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };
  };
}
