# Headless NixOS server (the mini PC): development stack over SSH/mosh.
{ config, ... }:
{
  features.server = {
    includes = with config.features; [
      nixos-base
      base
      development
      nix-gc
      _1password
    ];

    nixos =
      { lib, ... }:
      {
        imports = [ ../../legacy/modules/nixos ];

        nixos.bluetooth.enable = lib.mkDefault true;
        nixos.mosh.enable = lib.mkDefault true;
      };
  };
}
