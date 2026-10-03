# Geist for UI text, JetBrains Mono for code, and the JetBrains Mono Nerd
# Font only where icon glyphs are needed (sketchybar, and as the fallback
# for icons in UI and monospace text on Linux). Ghostty bundles its own Nerd
# Font symbols, so it uses plain JetBrains Mono.
let
  fonts =
    { pkgs, ... }:
    {
      fonts.packages = [
        pkgs.geist-font
        pkgs.jetbrains-mono
        pkgs.nerd-fonts.jetbrains-mono
      ];
    };
in
{
  features.fonts = {
    darwin = fonts;

    nixos = {
      imports = [ fonts ];

      # Apps that ask fontconfig for "sans-serif"/"monospace" (Noctalia, the
      # greeter, niri's overlay, Qt) get these; glyphs they lack, like Nerd
      # Font icons, come from the next entry.
      fonts.fontconfig.defaultFonts = {
        sansSerif = [
          "Geist"
          "JetBrainsMono Nerd Font"
        ];
        monospace = [
          "JetBrains Mono"
          "JetBrainsMono Nerd Font"
        ];
      };
    };

    # GTK and libadwaita read their fonts from GTK settings/dconf, not the
    # fontconfig aliases.
    homeManager =
      { lib, pkgs, ... }:
      lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        gtk.font = {
          name = "Geist";
          size = 11;
        };
        dconf.settings."org/gnome/desktop/interface".monospace-font-name = "JetBrains Mono 11";
      };
  };
}
