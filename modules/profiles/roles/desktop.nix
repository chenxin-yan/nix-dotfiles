# A machine I sit at: GUI apps and the desktop environment. Features for
# one OS do nothing on the other, so one list serves Macs and Linux.
{ config, ... }:
{
  features.desktop.includes = with config.features; [
    fleet
    fonts

    _1password
    espanso
    ghostty
    obsidian
    telegram
    todoist
    vesktop
    wechat

    aerospace
    iina
    kanata
    sketchybar
    zsa
  ];
}
