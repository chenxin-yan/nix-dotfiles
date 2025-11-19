{
  lib,
  config,
  ...
}:

{
  options = {
    app.linux.waybar.enable = lib.mkEnableOption "enables waybar status bar";
  };

  config = lib.mkIf config.app.linux.waybar.enable {
    programs.waybar = {
      enable = true;
    };
  };
}
