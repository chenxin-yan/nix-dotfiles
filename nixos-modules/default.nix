{ lib, config, ... }:

{
  imports = [
    ./sddm
    ./hyprland
  ];

  config = {
    nixos.sddm.enable = lib.mkDefault true;
    nixos.hyprland.enable = lib.mkDefault true;
  };
}
