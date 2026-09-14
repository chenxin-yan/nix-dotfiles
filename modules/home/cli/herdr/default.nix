{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  vim-herdr-navigation = pkgs.fetchFromGitHub {
    owner = "paulbkim-dev";
    repo = "vim-herdr-navigation";
    rev = "79679dacc791f70fc34de8b29a3cf9706c0f5b2f";
    hash = "sha256-iF0DLRn56eLGqY2iKTb3lX5iyVgl9CtSX5O2E5/pHjM=";
  };
in
{
  imports = [ inputs.herdr-micro.homeManagerModules.default ];

  options = {
    cli.herdr.enable = lib.mkEnableOption "enables herdr terminal workspace manager";
  };

  config = lib.mkIf config.cli.herdr.enable {
    home.packages = [ pkgs.herdr ];

    # Herdr has no plugin discovery; registration is a CLI side effect.
    home.activation.herdrNavigation = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.herdr}/bin/herdr plugin link ${vim-herdr-navigation}
    '';

    services.herdr-micro = {
      enable = pkgs.stdenv.hostPlatform.isDarwin;
      settings = {
        targets = {
          local.socket = "~/.config/herdr/herdr.sock";
          minipc.ssh = "cyan-minipc";
        };
      };
    };

    # Parity with the zellij setup: Ctrl+s leader, catppuccin, Alt-tab nav.
    # vim hjkl focus/resize, splits, and session persistence are herdr defaults.
    xdg.configFile."herdr/config.toml".text = ''
      onboarding = false

      [keys]
      prefix = "ctrl+s"
      detach = "prefix+d"
      new_tab = "prefix+n"
      previous_tab = "alt+i"
      next_tab = "alt+o"
      switch_tab = "ctrl+1..9"
      # Workspaces: Alt+Shift+P/N cycle prefix-free; prefix+arrow kept as
      # fallback and prefix+1..9 jumps direct.
      previous_workspace = ["prefix+up", "ctrl+shift+p"]
      next_workspace = ["prefix+down", "ctrl+shift+n"]
      switch_workspace = "prefix+1..9"
      previous_agent = "ctrl+shift+h"
      next_agent = "ctrl+shift+l"
      open_worktree = "prefix+shift+o"
      remove_worktree = "prefix+shift+c"

      split_vertical = "prefix+|"
      split_horizontal = "prefix+_"
      # prefix+s toggles the sidebar (frequent); move settings off it to prefix+,.
      toggle_sidebar = "prefix+s"
      settings = "prefix+comma"

      [[keys.command]]
      key = "ctrl+h"
      type = "plugin_action"
      command = "vim-herdr-navigation.left"

      [[keys.command]]
      key = "ctrl+j"
      type = "plugin_action"
      command = "vim-herdr-navigation.down"

      [[keys.command]]
      key = "ctrl+k"
      type = "plugin_action"
      command = "vim-herdr-navigation.up"

      [[keys.command]]
      key = "ctrl+l"
      type = "plugin_action"
      command = "vim-herdr-navigation.right"

      [ui]
      prompt_new_tab_name = false
      pane_borders = false

      [theme]
      name = "catppuccin"
    '';
  };
}
