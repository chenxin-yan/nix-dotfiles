{ lib, config, ... }:

{
  imports = [
    ./greetd
    ./hyprland
  ];

  config = {
    nixos.greetd.enable = lib.mkDefault true;
    nixos.hyprland.enable = lib.mkDefault true;
  };
}
