# Homerow: click anything with the keyboard (labels from the Accessibility
# tree), the Mac's counterpart to wl-kbptr on niri. The cask, like Raycast:
# Homerow updates itself and keeps one /Applications path for its
# Accessibility grant.
#
# Settings live in the com.superultra.Homerow defaults domain; shortcuts are
# the menu-symbol strings its settings window writes (modifiers in ⌃⌥⇧⌘
# order). The license is activated by hand on each Mac and stays out of git.
{
  features.homerow.darwin = {
    homebrew.casks = [ "homerow" ];

    system.defaults.CustomUserPreferences."com.superultra.Homerow" = {
      # Option+G labels everything clickable, niri's Mod+G (wl-kbptr).
      non-search-shortcut = "⌥G";
      search-shortcut = "⌥⇧G";
      # Not Homerow's ⌘⇧J (Helium's Downloads) nor ⌃⇧J (herdr's next_agent).
      scroll-shortcut = "⌥⇧S";
    };
  };
}
