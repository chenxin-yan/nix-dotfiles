{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    cli.taskwarrior.enable = lib.mkEnableOption "enables taskwarrior";
  };

  config = lib.mkIf config.cli.taskwarrior.enable {
    home.packages = with pkgs; [
      taskwarrior-tui
      taskwarrior3
    ];
  };
}
