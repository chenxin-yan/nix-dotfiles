# Development toolchain: coding agents, developer CLIs and languages.
{ config, ... }:
{
  features.development.includes = with config.features; [
    agents
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
