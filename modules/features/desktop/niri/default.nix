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
        # wl-copy/wl-paste: Neovim's "+ register and CLI tools use them.
        wl-clipboard
        # Clicks with the keyboard (Mod+G in binds.kdl); built with OpenCV.
        wl-kbptr
        # The GNOME portal's file chooser (Open/Save dialogs) is Nautilus
        # since xdg-desktop-portal-gnome 47 (niri's "Important Software").
        # Also a Finder-like file manager, and "Show in folder" target.
        nautilus
      ];
      # Trash, mounted drives and network places in Nautilus and the dialogs.
      services.gvfs.enable = true;
      # Space previews the selected file in Nautilus, like Quick Look.
      services.gnome.sushi.enable = true;

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

      # Opening a folder (xdg-open, yazi's own opener) lands in yazi, in
      # Ghostty (xdg.terminal-exec in gui/ghostty.nix). Explicit because
      # Nautilus, installed above for the file dialogs, also claims folders.
      xdg.mimeApps = {
        enable = true;
        defaultApplications."inode/directory" = "yazi.desktop";
      };

      # catppuccin/nix applies its Papirus icons and cursors through GTK.
      gtk.enable = true;
      catppuccin.cursors.enable = true;
      # Qt apps: catppuccin/nix themes Kvantum once Qt is on. qtct carries the
      # style and GTK's icon theme to Qt5 and Qt6 alike.
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "kvantum";
      }
      // lib.genAttrs [ "qt5ctSettings" "qt6ctSettings" ] (_: {
        Appearance = {
          style = "kvantum";
          icon_theme = config.gtk.iconTheme.name;
        };
      });
      home.pointerCursor = {
        enable = true;
        gtk.enable = true;
        size = 24;
      };
    };
}
