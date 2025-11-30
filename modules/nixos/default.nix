{ lib, config, ... }:

{
  imports = [
    ./sddm
    ./hyprland
    ./1password
  ];

  config = {
    nixos.sddm.enable = lib.mkDefault true;
    nixos.hyprland.enable = lib.mkDefault true;
    nixos._1password.enable = lib.mkDefault true;
  };
}
