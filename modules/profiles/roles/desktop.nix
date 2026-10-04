# A machine I sit at: GUI apps and the desktop environment. Features for
# one OS do nothing on the other, so one list serves Macs and Linux.
{ config, ... }:
{
  features.desktop.includes = with config.features; [
    fleet

    # Apps
    _1password
    espanso
    fonts
    ghostty
    helium
    obsidian
    telegram
    todoist
    vesktop
    viewers # Linux: mpv, imv, zathura
    wechat

    # Keyboards
    kanata # built-in laptop keyboard
    zsa # Voyager: Keymapp (+ udev rules on NixOS)
    xremap # Linux: Mac-style Super shortcuts

    # Mice
    logitech # Linux: Solaar for MX mice

    # Linux only: the niri desktop
    niri
    noctalia
    quiet-boot
    vicinae

    # macOS only
    aerospace
    iina
    sketchybar
  ];
}
