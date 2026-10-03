# Geist for UI text, JetBrains Mono for code, and the JetBrains Mono Nerd
# Font only where icon glyphs are needed (sketchybar, and as the fallback
# for icons in UI and monospace text on Linux). Ghostty bundles its own Nerd
# Font symbols, so it uses plain JetBrains Mono.
let
  sans = "Geist";
  mono = "JetBrains Mono";
  icons = "JetBrainsMono Nerd Font";

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
          sans
          icons
        ];
        monospace = [
          mono
          icons
        ];
      };
    };

    # GTK and libadwaita ask for their own defaults (Adwaita Sans/Mono), not
    # the fontconfig aliases; uninstalled, Adwaita Sans resolves to a CJK font.
    homeManager =
      { lib, pkgs, ... }:
      lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        gtk.font.name = sans;
        dconf.settings."org/gnome/desktop/interface".monospace-font-name = "${mono} 11";
      };
  };
}
