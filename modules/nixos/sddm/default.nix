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
  };
}
