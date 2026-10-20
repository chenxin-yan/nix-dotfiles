# OmniWM, a tiling window manager for macOS with niri's scrolling layout
# (nixpkgs' omniwm; Settings Reference: website/src/content/docs/config/ in
# OmniNull/OmniWM at the same tag).
#
# settings.toml belongs to the app as much as to Nix: the Settings window
# writes back to it, and an edit saved in the checkout applies live. So it is
# linked from the checkout rather than the store, and GUI changes show up as
# git diffs; OmniWM writes through the link to its target. The schema is
# strict: a missing key or a missing, unknown or duplicate hotkey id rejects
# the whole file, and OmniWM then runs on its defaults (the reason is in its
# Diagnostics). Edit values in place. A GUI save rewrites the file without
# comments, hence these notes. What it changes from OmniWM's defaults:
#   - hotkeys: niri's binds (niri/config/binds.kdl) on the same keys, Mod =
#     Option: Shift moves windows, Ctrl acts on displays. Option+1…9 go by
#     position on the focused display (workspace slots), as in niri. Defaults
#     that take a typed Option character (Option+T, Option+`, …) are
#     unassigned. Nothing uses Option+D or Option+Q (zsh's) or Option+Esc.
#   - niri.resizeStepPercent = 10: niri's ±10% column widths and heights.
#   - workspaces: nine, used by position like niri's; 1 is named "home".
#     Windows open where you are (no appRules route them). 1–7 live on the
#     Main display (ranked first in Settings → Monitors), 8–9 on the
#     Secondary; alone, the laptop holds all nine.
#   - workspaceBar.hideEmptyWorkspaces: Option+N/P skip empty workspaces.
#     The bar itself is off (sketchybar shows the workspaces, through IPC).
#     showFloatingWindows: the IPC workspace-bar events sketchybar follows
#     leave floating windows out otherwise, so a workspace holding only
#     floating windows would keep a stale pill.
#   - off: the Hidden Bar, the Quake terminal and clipboard history (Ghostty
#     and Raycast cover them), update checks (Nix pins the version).
#   - borders: off, no highlight around the focused window.
#   - appearance: automatic, so OmniWM's own windows follow macOS's light or
#     dark mode.
#   - focus: the pointer follows focus, and focus follows moved windows.
#   - gaps: 6 everywhere, 38 on top: 6pt below sketchybar (4–32pt).
#     OmniWM measures the top from the display's physical edge
#     and only past the menu bar (the notch strip on the laptop), so one
#     value clears the bar on every display, with no per-display override.
#     edgeGaps = false: the inner gap isn't added to the outer ones at the
#     screen edges. fullscreenUsesOuterGaps: a lone window (singleWindowFit
#     "fill") and Option+M take the fullscreen frame, which would otherwise
#     cover the bar.
{ config, ... }:
{
  # Reads Home Manager's dotfiles option, hence the paths include.
  features.omniwm.includes = with config.features; [ paths ];

  # "Displays have separate Spaces", the macOS default: OmniWM manages no
  # windows without it. A change needs a logout.
  features.omniwm.darwin.system.defaults.spaces.spans-displays = false;

  features.omniwm.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      # The package and its launchd agent. The release is Developer ID signed,
      # so its Accessibility and Input Monitoring grants survive a new store
      # path.
      programs.omniwm.enable = true;

      xdg.configFile."omniwm/settings.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/features/desktop/omniwm/settings.toml";
    };
}
