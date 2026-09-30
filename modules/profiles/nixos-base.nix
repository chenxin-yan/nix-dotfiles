# Minimal prerequisites for `just switch` on NixOS, without the optional
# features in ./server.nix. The wizard adds base and development alongside
# this; boot, disks, users, network and desktop stay with the host.
{ config, ... }:
{
  features.nixos-base.includes = with config.features; [
    nix-settings
    nh
  ];
}
