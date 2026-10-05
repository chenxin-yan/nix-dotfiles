# Logitech MX mice: OpenLogi remaps buttons and drives DPI and SmartShift over
# HID++. It fights Solaar and Options+ over the receiver, so only one can run.
# Until OpenLogi can pair Unifying devices, pair once with `nix run nixpkgs#solaar`.
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
