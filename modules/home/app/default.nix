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
in
{
  imports = [
    ./shared
    ./darwin
  ];

  # Conditionally enable based on platform
  config = lib.mkMerge [
    {
      # Shared apps are always available
      app.shared.ghostty.enable = lib.mkDefault true;
      app.shared.vesktop.enable = lib.mkDefault true;
      app.shared.espanso.enable = lib.mkDefault true;
      app.shared.zen-browser.enable = lib.mkDefault true;
      app.shared.todoist.enable = lib.mkDefault true;
      app.shared.telegram.enable = lib.mkDefault true;
    }

    # Darwin apps only on macOS
    (lib.mkIf isDarwin {
      app.darwin.kanata.enable = lib.mkDefault true;
      app.darwin.sketchybar.enable = lib.mkDefault true;
      app.darwin.iina.enable = lib.mkDefault true;
    })
  ];
}
