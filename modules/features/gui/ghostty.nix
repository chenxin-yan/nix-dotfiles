{
  features.ghostty.homeManager =
    { pkgs, lib, ... }:
    {
      programs.ghostty = {
        enable = true;
        # Source build is Linux-only in nixpkgs and upstream's flake (macOS app
        # needs Xcode/Swift); ghostty-bin repackages the official signed .dmg.
        package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
        settings = {
          # Icons come from Ghostty's bundled Nerd Font symbols.
          font-family = "JetBrains Mono";
          # Compensate for 2x Wayland scaling on Linux
          font-size = if pkgs.stdenv.hostPlatform.isLinux then 12 else 14;
          adjust-underline-position = 4;

          mouse-hide-while-typing = true;

          cursor-color = "cell-foreground";
          cursor-text = "cell-background";
          background-opacity = 0.98;
          background-blur = 30;
          window-theme = "ghostty";

          gtk-single-instance = true;
          window-padding-y = "2,0";
          window-padding-balance = true;
          macos-titlebar-style = "hidden";
          quit-after-last-window-closed = true;

          copy-on-select = "clipboard";
          shell-integration-features = "cursor,sudo,no-title";

          # Mac (Cmd) shortcuts on both systems; on Linux xremap leaves Ghostty
          # alone so these super binds reach it.
          # performable: lets the key through when there's nothing to copy or
          # paste, as Ghostty's own defaults do.
          keybind = [
            "performable:super+c=copy_to_clipboard"
            "performable:super+v=paste_from_clipboard"
            "super+w=close_surface"
            "super+t=new_tab"
            # Ghostty's macOS tab keys; Ctrl+Alt+H/L belong to the window
            # manager (niri and AeroSpace move windows with them).
            "super+shift+bracket_left=previous_tab"
            "super+shift+bracket_right=next_tab"
            # Linux defaults (save screen, new window, command palette) that would
            # swallow herdr's Ctrl+Shift+J/N/P before it sees them.
            "ctrl+shift+j=unbind"
            "ctrl+shift+n=unbind"
            "ctrl+shift+p=unbind"
            # Their Mac keys instead.
            "super+n=new_window"
            "super+shift+p=toggle_command_palette"
          ]
          ++ map (n: "super+${toString n}=goto_tab:${toString n}") (lib.range 1 9);
        };
      };
    };
}
