# Cross-platform GUI apps. macOS-only desktop pieces live in ./mac.nix.
# apps/zen-browser is not selected by any host.
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
