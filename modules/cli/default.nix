{ lib, config, ... }:

{
  imports = [
    ./opencode
    ./pandoc
    ./podman
    ./yazi
    ./zellij
    ./espanso
  ];

  config = {
    cli.opencode.enable = lib.mkDefault true;
    cli.pandoc.enable = lib.mkDefault true;
    cli.podman.enable = lib.mkDefault true;
    cli.yazi.enable = lib.mkDefault true;
    cli.zellij.enable = lib.mkDefault true;
    cli.espanso.enable = lib.mkDefault true;
  };
}
