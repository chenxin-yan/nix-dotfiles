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

  config = lib.mkIf config.dev.python.enable {
    home.packages = with pkgs; [
      sqlit-tui

      # editor
      sqlfluff
    ];
  };
}
