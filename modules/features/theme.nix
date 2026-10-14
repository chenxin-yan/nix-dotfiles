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

    homeManager = {
      imports = [ inputs.catppuccin.homeModules.catppuccin ];
      catppuccin = palette // {
        zsh-syntax-highlighting.enable = false;
      };
    };
  };
}
