{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    app.darwin.iina.enable = lib.mkEnableOption "enables IINA media player";
  };

  config = lib.mkIf config.app.darwin.iina.enable {
    # The nixpkgs `iina` package fetches the official signed IINA.dmg and
    # unpacks it; home-manager's targets.darwin.linkApps default makes it
    # discoverable in Spotlight via ~/Applications/Home Manager Apps/.
    home.packages = [ pkgs.iina ];
  };
}
