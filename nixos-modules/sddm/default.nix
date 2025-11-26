{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    nixos.sddm.enable = lib.mkEnableOption "enables SDDM display manager with Wayland support";
  };

  config = lib.mkIf config.nixos.sddm.enable {

    # gnome-keyring for SSH key management with PAM
    services.gnome.gnome-keyring.enable = true;

    # SDDM display manager
    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        enableHidpi = true;
        settings = {
          Autologin = {
            User = "cyan";
          };
        };
      };
    };

    security.pam.services.sddm.enableGnomeKeyring = true;
  };
}
