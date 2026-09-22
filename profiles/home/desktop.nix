# Opt-in GUI selections. Headless hosts simply do not import this file.
{ lib, pkgs, ... }:

{
  config = lib.mkMerge [
    {
      app.shared.ghostty.enable = lib.mkDefault true;
      app.shared.vesktop.enable = lib.mkDefault true;
      app.shared.espanso.enable = lib.mkDefault true;
      app.shared.zen-browser.enable = lib.mkDefault true;
      app.shared.todoist.enable = lib.mkDefault true;
      app.shared.telegram.enable = lib.mkDefault true;
    }

    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      app.darwin.kanata.enable = lib.mkDefault true;
      app.darwin.sketchybar.enable = lib.mkDefault true;
      app.darwin.iina.enable = lib.mkDefault true;
    })
  ];
}
