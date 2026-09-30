# GUI apps shared by Macs and NixOS desktops
{ config, ... }:
{
  features.apps.includes = with config.features; [
    ghostty
    vesktop
    espanso
    todoist
    telegram
  ];
}
