{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    codex
  ];

  home.file = {
    ".codex/config.toml".source = ./config/config.toml;
  };
}
