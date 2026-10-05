# Trial alongside herdr: same Ctrl+s leader, catppuccin and Ctrl+hjkl nav;
# everything else stays at tuios defaults to judge them as shipped, except
# keys the defaults can't have here (see the comments below).
{ inputs, ... }:
{
  features.tuios.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.tuios.packages.${pkgs.stdenv.hostPlatform.system}.default ];

      # tuios merges this over its defaults and leaves a read-only file alone,
      # but writers like `tuios hosts add` and the settings page can't persist:
      # add hosts here as [hosts.<name>] addr = "...".
      xdg.configFile."tuios/config.toml".text = ''
        [appearance]
        theme = "catppuccin_mocha"
        # Hands Ctrl+hjkl to nvim when tuios-nvim-navigator is active there.
        nvim_navigation = true

        # Type straight into the shell, as in herdr; Alt+Esc reaches window mode.
        [startup]
        start_in_terminal_mode = true
        tiled = true
        daemon = true

        [keybindings]
        leader_key = "ctrl+s"

        [keybindings.terminal_mode]
        terminal_focus_left = ["ctrl+h"]
        terminal_focus_down = ["ctrl+j"]
        terminal_focus_up = ["ctrl+k"]
        terminal_focus_right = ["ctrl+l"]

        # niri's resize keys without Mod: -/= width, Shift for height. Splitting
        # stays on Ctrl+s _ |. A bare "+" fails tuios's key validation, hence
        # only the chord spelling for it.
        [keybindings.layout]
        resize_master_shrink = ["-"]
        resize_master_grow = ["="]
        resize_height_shrink = ["_", "shift+-"]
        resize_height_grow = ["shift+="]
        split_horizontal = []
        equalize_splits = ["0"]

        # herdr's split key.
        [keybindings.prefix_mode]
        prefix_split_horizontal = ["_"]

        # The palette stays on Ctrl+s P; Ctrl+p goes back to nvim, fzf and zsh.
        [keybindings.global]
        command_palette = []

        # niri's mod key and AeroSpace both take Alt+1..9 before tuios sees
        # them (and Alt+Shift+1..9); Ctrl+1..9 were herdr's tab keys.
        [keybindings.workspaces]
        switch_workspace_1 = ["ctrl+1"]
        switch_workspace_2 = ["ctrl+2"]
        switch_workspace_3 = ["ctrl+3"]
        switch_workspace_4 = ["ctrl+4"]
        switch_workspace_5 = ["ctrl+5"]
        switch_workspace_6 = ["ctrl+6"]
        switch_workspace_7 = ["ctrl+7"]
        switch_workspace_8 = ["ctrl+8"]
        switch_workspace_9 = ["ctrl+9"]
        move_and_follow_1 = ["ctrl+shift+1"]
        move_and_follow_2 = ["ctrl+shift+2"]
        move_and_follow_3 = ["ctrl+shift+3"]
        move_and_follow_4 = ["ctrl+shift+4"]
        move_and_follow_5 = ["ctrl+shift+5"]
        move_and_follow_6 = ["ctrl+shift+6"]
        move_and_follow_7 = ["ctrl+shift+7"]
        move_and_follow_8 = ["ctrl+shift+8"]
        move_and_follow_9 = ["ctrl+shift+9"]
      '';
    };
}
