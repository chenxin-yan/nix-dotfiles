{ lib, ... }:

{
  imports = [
    ./base.nix
    ../cleanup-policy.nix
    ../../modules/nixos
  ];

  nix.gc.dates = "weekly";

  nixos.bluetooth.enable = lib.mkDefault true;
  nixos.mosh.enable = lib.mkDefault true;
}
