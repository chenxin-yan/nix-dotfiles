# Added to every *-darwin host: what nix-darwin needs to run this repo,
# plus settings that only exist for macOS.
{ config, ... }:
{
  features.darwin = {
    includes = with config.features; [
      nix-settings
      nh
    ];

    darwin = {
      # Fix macOS locale issue (BCP 47 format incompatible with Unix tools)
      environment.variables = {
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
      };

      # Every Mac deliberately removes unlisted Homebrew packages and
      # associated cask data; features add the casks they need.
      homebrew = {
        enable = true;
        brews = [
          "mole"
        ];
        onActivation = {
          cleanup = "zap";
        };
      };
    };
  };
}
