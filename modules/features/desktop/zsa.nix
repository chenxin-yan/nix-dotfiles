# ZSA keyboards (Voyager): the Keymapp configurator/flasher, plus the udev
# rules NixOS needs for Keymapp to reach the board. macOS needs no rules.
{
  features.zsa.darwin =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.keymapp ];
    };

  features.zsa.nixos =
    { pkgs, ... }:
    {
      hardware.keyboard.zsa.enable = true;
      environment.systemPackages = [ pkgs.keymapp ];
    };
}
