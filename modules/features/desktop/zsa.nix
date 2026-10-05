# ZSA keyboards (Voyager): the Keymapp configurator/flasher, plus the udev
# rules NixOS needs for Keymapp to reach the board. macOS needs no rules.
# Navigator Trackpad: Linux gets precision-touchpad gestures natively; macOS
# needs ZSA's companion app for them (zsa.io/navigator/trackpad).
{
  features.zsa.darwin =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.keymapp ];
      homebrew.casks = [ "navigator" ];
    };

  features.zsa.nixos =
    { pkgs, ... }:
    {
      hardware.keyboard.zsa.enable = true;
      environment.systemPackages = [ pkgs.keymapp ];
    };
}
