# Added to every *-darwin host: what nix-darwin needs to run this repo.
{ config, ... }:
{
  features.darwin.includes = with config.features; [
    nix-settings
    nh
    homebrew
    locale
  ];
}
