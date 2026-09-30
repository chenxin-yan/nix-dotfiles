# Full local development toolchain: language tools plus developer CLIs.
{ config, ... }:
{
  features.development.includes = with config.features; [
    herdr
    mise
    pandoc
    podman
    yazi
    zellij

    bash
    go
    java
    latex
    lua
    markdown
    nix
    python
    terraform
    typescript
    web
    c
    sql
  ];
}
