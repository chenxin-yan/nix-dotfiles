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
    # On Darwin the source build of `ghostty` is unsupported (needs Swift 6 +
    # xcodebuild, which the Nix Darwin stdenv doesn't provide). Use
    # `ghostty-bin`, which fetches the official signed Ghostty.dmg and
    # installs Ghostty.app into ~/Applications/Home Manager Apps via
    # home-manager's targets.darwin.linkApps default.
    home.packages =
      if pkgs.stdenv.isDarwin then [ pkgs.ghostty-bin ] else [ pkgs.ghostty ];

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
