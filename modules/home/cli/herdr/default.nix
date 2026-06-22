{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  options = {
    cli.herdr.enable = lib.mkEnableOption "enables herdr terminal workspace manager";
  };

  config = lib.mkIf config.cli.herdr.enable {
    home.packages = [
      inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # Parity with the zellij setup: Ctrl+s leader, catppuccin, Alt-tab nav.
    # vim hjkl focus/resize, splits, and session persistence are herdr defaults.
    xdg.configFile."herdr/config.toml".text = ''
      [keys]
      prefix = "ctrl+s"
      detach = "prefix+d"
      new_tab = "prefix+n"
      previous_tab = "alt+i"
      next_tab = "alt+o"
      switch_tab = "ctrl+1..9"
      # Workspaces: alt+[ / alt+] cycle prefix-free (free in AeroSpace, which
      # owns alt+hjkl/arrows/numbers); prefix+arrow kept as fallback and
      # prefix+1..9 jumps direct.
      previous_workspace = ["prefix+up", "alt+["]
      next_workspace = ["prefix+down", "alt+]"]
      switch_workspace = "prefix+1..9"
      open_worktree = "prefix+shift+o"
      remove_worktree = "prefix+shift+c"

      # Vertical split on prefix+| (zellij muscle memory).
      split_vertical = "prefix+|"
      # prefix+s toggles the sidebar (frequent); move settings off it to prefix+,.
      toggle_sidebar = "prefix+s"
      settings = "prefix+comma"

      [theme]
      name = "catppuccin"
    '';
  };
}
