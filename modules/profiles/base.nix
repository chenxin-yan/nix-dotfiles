# Shared preferences and core tools for every managed home.
{ config, ... }:
{
  features.base.includes = with config.features; [
    paths
    theme
    agents
    git
    jj
    nvim
    zsh
    utils
  ];
}
