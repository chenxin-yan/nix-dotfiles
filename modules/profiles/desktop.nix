# Cross-platform GUI apps. macOS-only desktop pieces live in ./mac.nix.
{
  features.desktop.homeManager =
    { lib, ... }:
    {
      app.shared.ghostty.enable = lib.mkDefault true;
      app.shared.vesktop.enable = lib.mkDefault true;
      app.shared.espanso.enable = lib.mkDefault true;
      app.shared.zen-browser.enable = lib.mkDefault true;
      app.shared.todoist.enable = lib.mkDefault true;
      app.shared.telegram.enable = lib.mkDefault true;
    };
}
