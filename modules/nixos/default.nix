{ lib, config, ... }:

{
  imports = [
    ./1password
    ./bluetooth
    ./mosh
  ];

  config = {
    nixos._1password.enable = lib.mkDefault true;
    nixos.bluetooth.enable = lib.mkDefault true;
    nixos.mosh.enable = lib.mkDefault true;
  };
}
