{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    app.shared.ghostty.enable = lib.mkEnableOption "enables ghostty terminal emulator";
  };

  config = lib.mkIf config.app.shared.ghostty.enable {
    # FIXME: currently ghostty package is broken upsteam for darwin.
    home.packages = pkgs.lib.optionals pkgs.stdenv.isLinux (
      with pkgs;
      [
        ghostty
      ]
    );

    home.file = {
      ".config/ghostty/config".source = ./config/config;
    };
  };
}
