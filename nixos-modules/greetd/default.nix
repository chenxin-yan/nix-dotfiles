{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    nixos.greetd.enable = lib.mkEnableOption "enables greetd display manager with regreet greeter";
  };

  config = lib.mkIf config.nixos.greetd.enable {
    # greetd display manager with regreet greeter
    services.greetd = {
      enable = true;
    };

    # regreet configuration
    programs.regreet = {
      enable = true;
      cageArgs = [
        "-s"
        "-m"
        "last"
      ];
    };

    # PAM configuration to unlock gnome-keyring on login
    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
