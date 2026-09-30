{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.sql.enable = lib.mkEnableOption "enables sql tools";
  };

  config = lib.mkIf config.dev.sql.enable {
    home.packages = with pkgs; [
      sqlit-tui

      # editor
      sqlfluff
    ];

    xdg.configFile."sqlit/settings.json".source = ./config/settings.json;
  };
}
