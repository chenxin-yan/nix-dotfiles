{ config, pkgs, ... }:

{
  imports = [
    ./lua
    ./nix
    ./markdown
  ];
}
