{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lua51Packages.lua
    lua51Packages.luarocks
    lua-language-server
    stylua
  ];
}
