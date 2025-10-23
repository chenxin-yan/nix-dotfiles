{ config, pkgs, ... }:

{
  programs.atuin = {
    enable = true;
    enableZshIntegration = false;
    daemon.enable = true;
    settings = {
      enter_accept = true;
      style = "compact";
      invert = true;
      history_filter = [
        "^c$"
        "^v$"
        "^cd"
        "^ns"
      ];
    };
  };

  programs.zsh = {
    initContent = ''
      eval "$(atuin init zsh --disable-up-arrow)"
    '';
  };
}
