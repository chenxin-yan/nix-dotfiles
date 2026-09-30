# Shared preferences and core tools for every managed home.
{ config, ... }:
{
  features.base = {
    includes = with config.features; [
      paths
      theme
      agents
      git
      jj
      nvim
      zsh
      nushell
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          tlrc
          tokei
          hyperfine
          devenv
          croc
          just

          bootdev-cli
          cloudflared
          vhs

          opencode
        ];

        # Let Home Manager install and manage itself.
        programs.home-manager.enable = true;

        programs.btop = {
          enable = true;
          settings = {
            vim_keys = true;
          };
        };
      };
  };
}
