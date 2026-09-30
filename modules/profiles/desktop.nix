# Shared desktop applications; each platform profile selects its own window/input/bar setup.
{ config, ... }:
{
  features.desktop.includes = with config.features; [
    _1password
    ghostty
    vesktop
    espanso
    todoist
    telegram
  ];
}
