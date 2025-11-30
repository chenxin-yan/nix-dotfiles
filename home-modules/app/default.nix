{
  lib,
  config,
  pkgs,
  ...
}:
let
  # Use the system directly from pkgs to avoid infinite recursion
  # This is safe because we're in a let binding, not in imports
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  imports = [
    ./shared
    ./darwin
    ./linux
  ];

  # Conditionally enable based on platform
  config = lib.mkMerge [
    {
      # Shared apps are always available
      app.shared.ghostty.enable = lib.mkDefault true;
      app.shared.thunderbird.enable = lib.mkDefault true;
      app.shared.vesktop.enable = lib.mkDefault true;
      app.shared.espanso.enable = lib.mkDefault true;
      app.shared.zen-browser.enable = lib.mkDefault true;
    }

    # Darwin apps only on macOS
    (lib.mkIf isDarwin {
      app.darwin.kanata.enable = lib.mkDefault true;
      app.darwin.sketchybar.enable = lib.mkDefault true;
    })

    # Linux apps only on Linux
    (lib.mkIf isLinux {
      app.linux.hyprland.enable = lib.mkDefault true;
      app.linux.waybar.enable = lib.mkDefault true;
    })
  ];
}
