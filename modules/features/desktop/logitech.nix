# Logitech MX mice: Solaar for Bolt pairing, battery, DPI and SmartShift. It
# also installs the udev rules it needs, and re-applies settings on reconnect.
{
  features.logitech.nixos = {
    programs.solaar = {
      enable = true;
      userService.enable = true;
    };
  };
}
