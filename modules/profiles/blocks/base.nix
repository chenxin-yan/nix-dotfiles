# Every managed home: shell, editor, version control and client tools.
{ config, ... }:
{
  features.base.includes = with config.features; [
    paths
    theme
    zsh
    nvim
    git
    jj
    utils
    ssh
    mosh
  ];
}
