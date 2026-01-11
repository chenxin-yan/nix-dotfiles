{ lib, config, ... }:

{
  imports = [
    ./opencode
    ./pandoc
    ./podman
    ./syncthing
    ./yazi
    ./zellij
    ./jj
  ];

  config = {
    cli.opencode.enable = lib.mkDefault true;
    cli.pandoc.enable = lib.mkDefault true;
    cli.podman.enable = lib.mkDefault true;
    cli.syncthing.enable = lib.mkDefault true;
    cli.yazi.enable = lib.mkDefault true;
    cli.zellij.enable = lib.mkDefault true;
    cli.jj.enable = lib.mkDefault true;
  };
}
