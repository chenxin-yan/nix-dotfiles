{ lib, config, ... }:

{
  imports = [
    ./sddm
    ./hyprland
    ./1password
    ./audio
    ./bluetooth
  ];

  config = {
    nixos.sddm.enable = lib.mkDefault true;
    nixos.hyprland.enable = lib.mkDefault true;
    nixos._1password.enable = lib.mkDefault true;
    nixos.audio.enable = lib.mkDefault true;
    nixos.bluetooth.enable = lib.mkDefault true;
  };
}
