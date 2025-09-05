{ config, pkgs, ... }:

{
  # FIXME: currently ghostty package is broken upsteam.
  # home.packages = with pkgs; [
  #   ghostty
  # ];

  home.file = {
    ".config/ghostty/config".source = ./config/config;
  };
}
