# Everyday command-line utilities for every managed home.
{
  features.utils.homeManager =
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
}
