{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pkgs.lua-language-server
    pkgs.stylua
  ];
}
