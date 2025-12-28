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
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      # Linux-specific: reduce font size to compensate for 2x Wayland scaling
      ".config/ghostty/config-linux".text = ''
        font-size = 12
      '';
    };
  };
}
