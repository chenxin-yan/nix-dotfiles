{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    opencode
  ];

  home.file = {
    ".config/opencode" = {
      source = ./config;
      recursive = true;
    };
  };
  programs.zsh = {
    shellAliases = {
      oc = "opencode";
      occ = "opencode run \"/commit analyze and commit staged changes\"";
    };
  };
}
