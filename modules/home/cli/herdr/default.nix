{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.herdr-micro.homeManagerModules.default ];

  options = {
    cli.herdr.enable = lib.mkEnableOption "enables herdr terminal workspace manager";
  };

  config = lib.mkIf config.cli.herdr.enable {
    home.packages = [ pkgs.herdr ];

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

      # Herdr plugins are runtime state: herdr plugin install paulbkim-dev/vim-herdr-navigation --ref v0.1.0 --yes
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
