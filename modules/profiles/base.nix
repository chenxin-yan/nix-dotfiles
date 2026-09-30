# Shared preferences and core tools for every managed home.
{ config, ... }:
{
  features.base = {
    includes = with config.features; [
      paths
      theme
    ];

    homeManager =
      { pkgs, lib, ... }:
      {
        imports = [ ../../legacy/modules/home ];

        agents.enable = lib.mkDefault true;
        core.git.enable = lib.mkDefault true;
        core.jj.enable = lib.mkDefault true;
        core.nvim.enable = lib.mkDefault true;
        core.zsh.enable = lib.mkDefault true;
        core.nushell.enable = lib.mkDefault true;

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
