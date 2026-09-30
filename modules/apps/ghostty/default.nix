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
          font-family = "JetBrainsMono Nerd Font";
          # Compensate for 2x Wayland scaling on Linux
          font-size = if pkgs.stdenv.hostPlatform.isLinux then 12 else 14;
          adjust-underline-position = 4;

          mouse-hide-while-typing = true;

          cursor-invert-fg-bg = true;
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

          keybind = [
            "super+w=close_surface"
            "super+t=new_tab"
            "ctrl+alt+h=previous_tab"
            "ctrl+alt+l=next_tab"
          ]
          ++ map (n: "super+${toString n}=goto_tab:${toString n}") (lib.range 1 9);
        };
      };
    };
}
