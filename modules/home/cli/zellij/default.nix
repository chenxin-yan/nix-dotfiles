{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    cli.zellij.enable = lib.mkEnableOption "enables zellij terminal multiplexer";
  };

  config = lib.mkIf config.cli.zellij.enable {
    home.packages = with pkgs; [
      zellij
    ];

    xdg.configFile."zellij" = {
      source = ./config;
      recursive = true;
    };
  };
}
