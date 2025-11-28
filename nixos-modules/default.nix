{ lib, config, ... }:

{
  imports = [
    ./sddm
    ./hyprland
    ./1password
    ./chromium
  ];

  config = {
    nixos.sddm.enable = lib.mkDefault true;
    nixos.hyprland.enable = lib.mkDefault true;
    nixos._1password.enable = lib.mkDefault true;
    nixos.chromium.enable = lib.mkDefault true;
  };
}
