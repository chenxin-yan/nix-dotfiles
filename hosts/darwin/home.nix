{ config, pkgs, ... }:

{

  imports = [ ../home.nix ];

  home.packages = with pkgs; [
  ];

  home.file = {

  };
}
