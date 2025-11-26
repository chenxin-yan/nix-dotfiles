{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    app.linux.firefox.enable = lib.mkEnableOption "enables Firefox web browser";
  };

  config = lib.mkIf config.app.linux.firefox.enable {
    programs.firefox = {
      enable = true;
    };
  };
}
