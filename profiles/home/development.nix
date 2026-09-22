# Full local development toolchain: language tools plus developer CLIs.
# Syncthing is a per-host topology decision, not part of development.
{ lib, ... }:

{
  config = {
    cli.gcloud.enable = lib.mkDefault true;
    cli.herdr.enable = lib.mkDefault true;
    cli.mise.enable = lib.mkDefault true;
    cli.pandoc.enable = lib.mkDefault true;
    cli.pi.enable = lib.mkDefault true;
    cli.podman.enable = lib.mkDefault true;
    cli.yazi.enable = lib.mkDefault true;
    cli.zellij.enable = lib.mkDefault true;

    dev.bash.enable = lib.mkDefault true;
    dev.go.enable = lib.mkDefault true;
    dev.java.enable = lib.mkDefault true;
    dev.latex.enable = lib.mkDefault true;
    dev.lua.enable = lib.mkDefault true;
    dev.markdown.enable = lib.mkDefault true;
    dev.nix.enable = lib.mkDefault true;
    dev.python.enable = lib.mkDefault true;
    dev.terraform.enable = lib.mkDefault true;
    dev.typescript.enable = lib.mkDefault true;
    dev.web.enable = lib.mkDefault true;
    dev.c.enable = lib.mkDefault true;
    dev.sql.enable = lib.mkDefault true;
  };
}
