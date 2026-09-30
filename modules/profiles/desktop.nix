# Cross-platform GUI apps. macOS-only desktop pieces live in ./mac.nix.
{ config, ... }:
{
  features.desktop.includes = with config.features; [
    ghostty
    vesktop
    espanso
    todoist
    telegram
  ];
}
