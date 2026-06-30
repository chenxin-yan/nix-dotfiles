{ lib, config, ... }:

{
  imports = [
    ./1password
    ./bluetooth
    ./mosh
    ./podman
  ];

  config = {
    nixos._1password.enable = lib.mkDefault true;
    nixos.bluetooth.enable = lib.mkDefault true;
    nixos.mosh.enable = lib.mkDefault true;
    nixos.podman.enable = lib.mkDefault true;
  };
}
