{ config, pkgs, ... }:

{
  imports = [
    ./git
    ./zsh
    ./yazi
    ./nvim
  ];
}
