# Added to every *-linux host: prerequisites for `just switch` on NixOS.
# Boot, disks, users and network stay with the host.
{ config, ... }:
{
  features.nixos.includes = with config.features; [
    nix-settings
    nh
  ];
}
