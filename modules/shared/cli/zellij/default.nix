{ config, pkgs, ... }:

{
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
}
