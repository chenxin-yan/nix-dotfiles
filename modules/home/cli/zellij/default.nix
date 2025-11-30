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
    programs.zellij = {
      enable = true;
      # enableZshIntegration = true;
      # attachExistingSession = true;
      # exitShellOnExit = true;
    };

    xdg.configFile."zellij" = {
      source = ./config;
      recursive = true;
    };
  };
}
