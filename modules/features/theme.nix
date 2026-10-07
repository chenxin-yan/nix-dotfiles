# Catppuccin Mocha / Lavender everywhere catppuccin/nix has a module.
{ inputs, ... }:
let
  palette = {
    autoEnable = true;
    enable = true;
    flavor = "mocha";
    accent = "lavender";
  };
in
{
  features.theme = {
    nixos = {
      imports = [ inputs.catppuccin.nixosModules.catppuccin ];
      catppuccin = palette;
    };

    homeManager =
      { pkgs, ... }:
      {
        imports = [ inputs.catppuccin.homeModules.catppuccin ];
        catppuccin = palette // {
          zsh-syntax-highlighting.enable = false;
          # TODO: drop once catppuccin/nix's pinned lazygit source includes
          # catppuccin/lazygit#65. lazygit 0.66 migrates `gui.authorColors`
          # to `gui.theme.authorColors` and exits when it can't write the
          # migrated theme back to the read-only store path.
          sources.lazygit =
            inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.lazygit.overrideAttrs
              {
                src = pkgs.fetchFromGitHub {
                  owner = "phucisstupid";
                  repo = "lazygit";
                  rev = "5330145af56b838f4b0fb172013697eb37f32f4d";
                  hash = "sha256-hb6W9WwBOtsq+TFw72P17BQCMtHJ3y0um2rSiXOzVZ8=";
                };
              };
        };
      };
  };
}
