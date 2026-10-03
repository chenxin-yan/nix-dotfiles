# Trial alongside herdr: same Ctrl+s leader, catppuccin and Ctrl+hjkl nav;
# everything else stays at tuios defaults to judge them as shipped.
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

        [keybindings]
        leader_key = "ctrl+s"

        [keybindings.terminal_mode]
        terminal_focus_left = ["ctrl+h"]
        terminal_focus_down = ["ctrl+j"]
        terminal_focus_up = ["ctrl+k"]
        terminal_focus_right = ["ctrl+l"]
      '';
    };
}
