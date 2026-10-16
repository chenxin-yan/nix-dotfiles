{ inputs, ... }:
{
  features.logitech = {
    darwin.homebrew.casks = [ "openlogi" ];

    nixos = {
      imports = [ inputs.openlogi.nixosModules.default ];
      programs.openlogi.enable = true;
    };
  };
}
