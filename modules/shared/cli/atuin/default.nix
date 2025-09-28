{ config, pkgs, ... }:

{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    daemon.enable = true;
    settings = {
      enter_accept = true;
      history_filter = [
        "^c$"
        "^G$"
        "^e$"
        "^v$"
        "^cd"
        "^ns"
      ];
    };

  };
}
