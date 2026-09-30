# Headless NixOS server (the mini PC): development stack over SSH/mosh.
{ config, ... }:
{
  features.server = {
    includes = with config.features; [
      nixos-base
      base
      development
      nix-gc
      unfree
      tailscale
      ssh
      _1password
      bluetooth
      mosh
    ];

  };
}
