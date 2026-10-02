# niri, a scrollable-tiling Wayland compositor. The KDL config is linked from
# the checkout rather than copied into the store: niri reloads it on save, so
# tweaks need no rebuild. `niri validate -c <file>` checks an edit.
{ config, ... }:
{
  features.niri.includes = with config.features; [ paths ];

  features.niri.nixos =
    { pkgs, ... }:
    {
      # Also sets up the session, portals (screencast, file chooser) and
      # gnome-keyring, per niri's "Important Software" page.
      programs.niri.enable = true;

      environment.systemPackages = with pkgs; [
        # niri spawns it on demand when an X11 client connects.
        xwayland-satellite
        playerctl
      ];

      # Electron and Chromium apps run natively on Wayland.
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    };

  features.niri.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      xdg.configFile."niri".source =
        config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/features/desktop/niri/config";

      # catppuccin/nix applies its Papirus icons and cursors through GTK.
      gtk.enable = true;
      catppuccin.cursors.enable = true;
      home.pointerCursor = {
        enable = true;
        gtk.enable = true;
        size = 24;
      };
    };
}
