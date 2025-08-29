{ config, pkgs, ... }:

{

  home.username = "yanchenxin";
  home.homeDirectory = "/Users/yanchenxin";

  imports = [ ../home.nix ];

  home.packages = with pkgs; [
  ];

  home.file = {

  };
}
