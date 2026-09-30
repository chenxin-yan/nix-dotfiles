let
  settings.nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
in
{
  features.nix-settings = {
    darwin = settings;
    nixos = settings;
  };
}
